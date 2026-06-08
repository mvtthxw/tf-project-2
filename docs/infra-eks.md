# Infrastructure: EKS (cluster module)

The **eks** module provisions the EKS control plane, a managed node group, a Fargate profile, core cluster addons, and the IAM role for the VPC CNI plugin.

**Terraform path:** [terraform/eks-infra/modules/eks/](../terraform/eks-infra/modules/eks/)

**Invoked from:** [terraform/eks-infra/main.tf](../terraform/eks-infra/main.tf) as `module "eks"`.

**Depends on:** network module outputs (`vpc_id`, `private_subnets`).

See also: [docs/infra.md](infra.md) | [docs/infra-vpc.md](infra-vpc.md) | [docs/infra-controllers.md](infra-controllers.md)

## Purpose

Run a single EKS cluster with:

- one **managed node group** for workloads like `app-managed`,
- one **Fargate profile** for the `fargate-apps` namespace (used by `app-fargate`),
- core **addons** (`vpc-cni`, `kube-proxy`, `coredns`) installed and kept up to date,
- **IRSA** enabled so service accounts can assume IAM roles (used by addons and the controllers module).

## Naming

Prefix: `<username>-<repo>-<environment>` (from `general`).

| Resource    | Name pattern              | Example (defaults)                    |
| ----------- | ------------------------- | ------------------------------------- |
| Cluster     | `<prefix>-eks`            | `mvtthxw-k8s-php-infra-dev-eks`       |
| Node group  | `<username>-node-group`   | `mvtthxw-node-group`                  |
| VPC CNI role| `<prefix>-vpc-cni-role`   | `mvtthxw-k8s-php-infra-dev-vpc-cni-role` |

Defined in [locals.tf](../terraform/eks-infra/modules/eks/locals.tf).

## Upstream module

Built with `terraform-aws-modules/eks/aws` **v21.20.0** - see [eks.tf](../terraform/eks-infra/modules/eks/eks.tf).

## Configuration

Set via the `eks` object in [terraform/eks-infra/terraform.tfvars](../terraform/eks-infra/terraform.tfvars):

| Variable                        | Default           | Notes                              |
| ------------------------------- | ----------------- | ---------------------------------- |
| `eks.cluster_version`           | `1.35`            | Kubernetes version                 |
| `eks.node_group_desired_size`   | `1`               | Target node count                  |
| `eks.node_group_min_size`       | `1`               | Minimum (Cluster Autoscaler floor) |
| `eks.node_group_max_size`       | `2`               | Maximum (Cluster Autoscaler ceiling) |
| `eks.node_group_disk_size`      | `20`              | GB per node                        |
| `eks.node_group_instance_types` | `["t3.medium"]`   | On-demand instances                |

## Cluster settings

- **Subnets** - private subnets from the network module (`var.private_subnets`).
- **IRSA** - enabled (`enable_irsa = true`).
- **Cluster creator admin** - enabled (`enable_cluster_creator_admin_permissions = true`).
- **CloudWatch log group** - not created (`create_cloudwatch_log_group = false`).
- **API endpoint** - both public and private access enabled.
- **Dataplane wait** - 60 seconds after compute resources before proceeding.

## Managed node group

Single node group keyed by `local.eks_managed_node_group_name`:

- **Capacity type:** ON_DEMAND
- **IAM:** role created per node group, CNI policy attached (`iam_role_attach_cni_policy = true`)
- **Scaling:** min / desired / max from `terraform.tfvars` (defaults: 1 / 1 / 2)

The Cluster Autoscaler (installed by the controllers module) can scale the group between `min_size` and `max_size` based on pending pods.

## Fargate profile

Profile name `default`, selector:

```hcl
namespace = "fargate-apps"
```

Pods scheduled in the `fargate-apps` namespace run on Fargate instead of the managed node group. This is where `app-fargate` is intended to run.

## Addons

Installed via the EKS module's `addons` block, pinned to **most recent** compatible versions:

| Addon        | Notes                                                                 |
| ------------ | --------------------------------------------------------------------- |
| `vpc-cni`    | Uses dedicated IRSA role (`service_account_role_arn`); runs before compute |
| `kube-proxy` | Runs before compute                                                   |
| `coredns`    | Installed after compute is available                                  |

Conflict resolution: `OVERWRITE` on both create and update.

## VPC CNI IRSA role

Separate IAM role in [iam-vpc-cni.tf](../terraform/eks-infra/modules/eks/iam-vpc-cni.tf), built with `terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts` v6.6.0:

- **Trust:** EKS OIDC provider, service account `kube-system:aws-node`
- **Policy:** AWS-managed VPC CNI policy (`attach_vpc_cni_policy = true`)
- **Extra permission:** `ec2:DescribeSecurityGroups` on `*` - required because VPC CNI >= 1.22 enables subnet discovery by default and the module's built-in IPv4 policy does not yet include this action

This role is wired into the `vpc-cni` addon via `service_account_role_arn`.

## Node security group

Additional ingress rules on the node security group (beyond EKS defaults):

| Port | Protocol | Source      | Purpose              |
| ---- | -------- | ----------- | -------------------- |
| 80   | TCP      | `0.0.0.0/0` | HTTP to node pods    |
| 443  | TCP      | `0.0.0.0/0` | HTTPS to node pods   |

## Cluster Autoscaler tags

The cluster is tagged for Cluster Autoscaler auto-discovery:

```
k8s.io/cluster-autoscaler/enabled               = "true"
k8s.io/cluster-autoscaler/<cluster_name>        = "owned"
```

These tags are required by the Cluster Autoscaler Helm release in the controllers module.

## Timeouts

| Resource        | Create / delete timeout |
| --------------- | ----------------------- |
| Cluster         | 45m                     |
| Node group      | 45m (create/update/delete) |
| Addons          | 30m (create/update/delete) |

Plan for a long `terraform apply` on first run.

## Root providers (kubernetes + helm)

The root stack [versions.tf](../terraform/eks-infra/versions.tf) configures `kubernetes` and `helm` providers using outputs from this module:

```hcl
data "aws_eks_cluster_auth" "auth" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  token                  = data.aws_eks_cluster_auth.auth.token
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
}
```

This lets the **controllers** module install Helm charts in the same `terraform apply` that creates the cluster.

## Outputs

Module outputs ([outputs.tf](../terraform/eks-infra/modules/eks/outputs.tf)) re-exported at root:

| Output                              | Use case                                    |
| ----------------------------------- | ------------------------------------------- |
| `cluster_id` / `cluster_name`       | `aws eks update-kubeconfig`, autoscaler     |
| `cluster_endpoint`                  | kubectl / provider config                   |
| `cluster_certificate_authority_data`| Provider TLS                                |
| `cluster_oidc_issuer_url`           | IRSA debugging                              |
| `oidc_provider_arn`                 | Passed to controllers module for IRSA roles |
| `eks_managed_node_groups`           | Node group status                           |
| `fargate_profiles`                  | Fargate profile status                      |
| `node_security_group_id`            | Security group reference                    |

## Files

| File              | Role                                |
| ----------------- | ----------------------------------- |
| `eks.tf`          | EKS module invocation               |
| `iam-vpc-cni.tf`  | IRSA role for VPC CNI addon         |
| `variables.tf`    | `general`, `eks`, VPC inputs        |
| `outputs.tf`      | Cluster and OIDC outputs            |
| `locals.tf`       | Naming (cluster, node group, roles) |
| `versions.tf`     | Provider constraints                |

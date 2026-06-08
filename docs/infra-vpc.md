# Infrastructure: VPC (network module)

The **network** module creates the isolated AWS network that the EKS cluster runs in. It has no knowledge of Kubernetes - it only provisions a VPC, subnets, and routing.

**Terraform path:** [terraform/eks-infra/modules/network/](../terraform/eks-infra/modules/network/)

**Invoked from:** [terraform/eks-infra/main.tf](../terraform/eks-infra/main.tf) as `module "network"`.

See also: [docs/infra.md](infra.md) for the overall stack layout.

## Purpose

Provide a dedicated VPC with public and private subnets across multiple Availability Zones. The EKS control plane and worker nodes use **private subnets**; public subnets host the NAT gateway and any resources that need direct internet access.

## Naming

Resources are named using a prefix derived from the `general` variable:

```
<prefix> = <username>-<repo>-<environment>
VPC name = <prefix>-vpc
```

Example with defaults from [terraform/eks-infra/terraform.tfvars](../terraform/eks-infra/terraform.tfvars): `mvtthxw-k8s-php-infra-dev-vpc`.

Defined in [locals.tf](../terraform/eks-infra/modules/network/locals.tf).

## Upstream module

Built with `terraform-aws-modules/vpc/aws` **v6.6.1** - see [vpc.tf](../terraform/eks-infra/modules/network/vpc.tf).

## Configuration

Set via the `vpc` object in [terraform/eks-infra/terraform.tfvars](../terraform/eks-infra/terraform.tfvars):

| Variable       | Default in repo | Meaning              |
| -------------- | --------------- | -------------------- |
| `vpc.cidr`     | `10.100.0.0/20` | VPC CIDR block       |
| `vpc.az_count` | `2`             | Number of AZs to use |

Availability Zones are picked automatically from the region (`data.aws_availability_zones.available`), sliced to `az_count`.

## Subnet layout

For each AZ index `i` (0-based):

| Type    | CIDR formula                    | Example (i=0, cidr=`10.100.0.0/20`) |
| ------- | ------------------------------- | ----------------------------------- |
| Public  | `cidrsubnet(cidr, 4, i)`       | `10.100.0.0/24`                     |
| Private | `cidrsubnet(cidr, 4, i + 10)`  | `10.100.10.0/24`                    |

Private subnets are offset by 10 in the subnet index so public and private ranges don't overlap within the VPC.

## Design choices

- **Single NAT gateway** (`single_nat_gateway = true`) - one NAT for all private subnets instead of one per AZ. Lower cost; acceptable for a dev / lab environment.
- **No VPN gateway** (`enable_vpn_gateway = false`).
- **Public IPs on launch** (`map_public_ip_on_launch = true`) - instances in public subnets get a public IP automatically.

## Outputs

The module exposes standard VPC outputs via [outputs.tf](../terraform/eks-infra/modules/network/outputs.tf). These are re-exported at the root stack level in [terraform/eks-infra/outputs.tf](../terraform/eks-infra/outputs.tf).

| Output                   | Consumed by                          |
| ------------------------ | ------------------------------------ |
| `vpc_id`                 | EKS module, controllers module (ALB) |
| `private_subnets`        | EKS module (worker / control plane)  |
| `public_subnets`         | NAT gateway placement                |
| `vpc_cidr_block`         | Reference / debugging                |
| `nat_gateway_ids`        | Reference / debugging                |
| `internet_gateway_id`    | Reference / debugging                |
| `public_route_table_ids` | Reference / debugging                |
| `private_route_table_ids`| Reference / debugging                |
| `availability_zones`     | Reference / debugging                |

## Files

| File           | Role                                      |
| -------------- | ----------------------------------------- |
| `vpc.tf`       | VPC module invocation                     |
| `variables.tf` | `general` and `vpc` input objects         |
| `outputs.tf`   | Re-exports from the upstream VPC module   |
| `locals.tf`    | VPC name prefix                           |
| `data.tf`      | `aws_availability_zones` data source      |
| `versions.tf`  | Provider version constraints for the module |

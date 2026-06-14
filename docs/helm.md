# Helm charts

Local Helm charts for deploying the two PHP demo apps to EKS. Charts live in [helm/](../helm/) at the repository root and are installed automatically by the Terraform **app** module during `terraform apply` in `terraform/eks-infra/`.

See also: [docs/infra-app.md](infra-app.md) | [docs/app.md](app.md) | [docs/infra-controllers.md](infra-controllers.md)

## Layout

```
helm/
├── app-managed/
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
│       ├── deployment.yaml
│       ├── service.yaml
│       ├── ingress.yaml
│       ├── namespace.yaml
│       ├── secret.yaml
│       └── _helpers.tpl
└── app-fargate/
    ├── Chart.yaml
    ├── values.yaml
    └── templates/
        ├── deployment.yaml
        ├── service.yaml
        ├── ingress.yaml
        ├── namespace.yaml
        └── _helpers.tpl
```

Both charts are **application** charts (`type: application`, chart version `0.1.0`). The chart version is independent of the container image tag (which comes from `app/<app>/.version` and ECR).

## What each chart deploys

| Chart | App behaviour | Target compute | Namespace default |
| ----- | ------------- | -------------- | ----------------- |
| `app-managed` | Shows version, hostname, **PARAMS_STORE** | EKS managed node group | `managed-apps` |
| `app-fargate` | Shows version, hostname, **current time** | EKS Fargate | `fargate-apps` |

This matches the PHP sources in [app/app-managed](../app/app-managed) and [app/app-fargate](../app/app-fargate).

## Shared design

Both charts render the same resource types:

- **Namespace** (optional, controlled by `namespace.create`)
- **Deployment** — single container on port 80, HTTP readiness/liveness probes on `/`
- **Service** — ClusterIP on port 80
- **Ingress** — AWS ALB via `ingressClassName: alb`

Common Ingress annotations (from `values.yaml`):

```yaml
alb.ingress.kubernetes.io/scheme: internet-facing
alb.ingress.kubernetes.io/target-type: ip
alb.ingress.kubernetes.io/group.name: shared-apps
alb.ingress.kubernetes.io/healthcheck-path: /
alb.ingress.kubernetes.io/success-codes: "200"
```

The shared `group.name` puts both apps on **one ALB** with different listener ports. Requires the AWS Load Balancer Controller (installed by the controllers module).

## `app-managed` chart

### Key values ([values.yaml](../helm/app-managed/values.yaml))

| Value | Default | Set by Terraform |
| ----- | ------- | ---------------- |
| `image.repository` | `""` (required) | ECR URL from data source |
| `image.tag` | `v1.0.0` | `app.managed_app_image_tag` |
| `replicaCount` | `1` | `app.managed_app_replica_count` |
| `namespace.name` | `managed-apps` | `app.managed_app_namespace` |
| `ssm.parameterValue` | `""` | SSM parameter value |
| `ingress.annotations` listen port | HTTP **8082** | (static in values) |

### PARAMS_STORE via Secret

When `ssm.parameterValue` is non-empty, [templates/secret.yaml](../helm/app-managed/templates/secret.yaml) creates a Secret `{release-name}-env` with key `PARAMS_STORE`. The Deployment reads it via `env.valueFrom.secretKeyRef`.

Terraform creates the SSM parameter and passes its value into Helm — see [docs/infra-app.md](infra-app.md#ssm-parameter-app-managed).

### Resources

Default requests/limits: 500m CPU, 512Mi memory.

## `app-fargate` chart

### Key values ([values.yaml](../helm/app-fargate/values.yaml))

| Value | Default | Set by Terraform |
| ----- | ------- | ---------------- |
| `image.repository` | `""` (required) | ECR URL from data source |
| `image.tag` | `v1.0.0` | `app.fargate_app_image_tag` |
| `replicaCount` | `1` | `app.fargate_app_replica_count` |
| `namespace.name` | `fargate-apps` | `app.fargate_app_namespace` |
| `ingress.annotations` listen port | HTTP **8081** | (static in values) |

No Secret template — the app displays server time, not SSM parameters.

Pods in `fargate-apps` are scheduled on **Fargate** via the EKS Fargate profile defined in the eks module.

### Resources

Default requests/limits: 500m CPU, 1Gi memory (Fargate minimum considerations).

## Default install (Terraform)

The normal path is Terraform — no manual `helm install` needed:

```bash
cd terraform/eks-infra
terraform apply
```

Prerequisites: ECR images pushed, cluster and controllers up. The app module runs last.

## Manual install (debugging)

To install or upgrade a chart by hand (e.g. against a local cluster or for debugging):

```bash
# Example: app-managed
helm upgrade --install app-managed ./helm/app-managed \
  --namespace managed-apps \
  --create-namespace \
  --set image.repository=<ecr-url> \
  --set image.tag=v1.0.0 \
  --set ssm.parameterValue="debug value" \
  --set namespace.create=false
```

```bash
# Example: app-fargate
helm upgrade --install app-fargate ./helm/app-fargate \
  --namespace fargate-apps \
  --create-namespace \
  --set image.repository=<ecr-url> \
  --set image.tag=v1.0.0 \
  --set namespace.create=false
```

Manual installs bypass Terraform state — prefer `terraform apply` for the managed workflow.

## Customising a chart

1. Edit templates or [values.yaml](../helm/app-managed/values.yaml) / [values.yaml](../helm/app-fargate/values.yaml).
2. If Terraform sets the value, also update the matching `helm_release` `set` block in [terraform/eks-infra/modules/app/](../terraform/eks-infra/modules/app/).
3. Re-apply or run `helm upgrade` manually.

Common customisations:

- **Replicas** — `replicaCount` in values or `terraform.tfvars`
- **Ingress port** — `ingress.annotations.alb.ingress.kubernetes.io/listen-ports` in values
- **Resources** — `resources` block in values
- **PARAMS_STORE value** — `managed_app_ssm_value` in `terraform.tfvars`

## Verification

```bash
helm list -A | grep app-
kubectl get all -n managed-apps
kubectl get all -n fargate-apps
kubectl get ingress -n managed-apps
kubectl get ingress -n fargate-apps
```

After the ALB controller provisions the load balancer, test:

- `http://<alb-dns>:8081` → app-fargate (time)
- `http://<alb-dns>:8082` → app-managed (param store)

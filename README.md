# tf-eks-php-apps

EKS-based playground running two small PHP demo apps (`app-managed` and `app-fargate`). Infrastructure is described as Terraform code split into two independent stacks - an **ECR** stack for the container registries and an **EKS + VPC** stack for the cluster, controllers, and app deployments - so the expensive part can be torn down between sessions while the images stay around. Local development happens inside a Dev Container with Terraform, AWS CLI, kubectl, Helm, PHP, Python and Docker-in-Docker preinstalled.

## Repository layout

- [`app/`](app) - the two PHP demo apps, `docker-compose.yml` for local smoke testing, and `build_and_push.py` to build and push images to ECR.
- [`helm/`](helm) - Helm charts for deploying both apps to EKS (`app-managed`, `app-fargate`).
- [`terraform/ecr/`](terraform/ecr) - Terraform stack for the AWS ECR repositories.
- [`terraform/eks-infra/`](terraform/eks-infra) - Terraform stack for VPC, EKS cluster, Helm controllers, and application deployments.
- [`.devcontainer/`](.devcontainer) - Dev Container definition with all required tooling.
- [`docs/`](docs) - project documentation (see below).

## Documentation

- [docs/development.md](docs/development.md) - dev container setup, Colima, AWS credentials via `.env`.
- [docs/app.md](docs/app.md) - the two PHP apps, versioning via `.version`, local `docker compose` runs, and `build_and_push.py` for ECR.
- [docs/helm.md](docs/helm.md) - Helm chart structure, values, and manual install reference.
- [docs/infra.md](docs/infra.md) - infrastructure overview, ECR stack, workflow, remote state.
- [docs/infra-vpc.md](docs/infra-vpc.md) - VPC / network module.
- [docs/infra-eks.md](docs/infra-eks.md) - EKS cluster module.
- [docs/infra-controllers.md](docs/infra-controllers.md) - Helm controllers (ALB, autoscaler, Secrets Store CSI).
- [docs/infra-app.md](docs/infra-app.md) - application Terraform module (Helm releases + SSM).

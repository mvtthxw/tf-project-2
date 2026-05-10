# tf-project-2

EKS-based playground running two small PHP demo apps (`app-managed` and `app-fargate`). Infrastructure is described as Terraform code split into two independent stacks - an **ECR** stack for the container registries and an **EKS + VPC** stack for the cluster - so the expensive part can be torn down between sessions while the images stay around. Local development happens inside a Dev Container with Terraform, AWS CLI, kubectl, Helm, PHP and Docker-in-Docker preinstalled.

## Repository layout

- [`app/`](app) - the two PHP demo apps and a `docker-compose.yml` for local smoke testing.
- [`terraform/ecr/`](terraform/ecr) - Terraform stack for the AWS ECR repositories.
- [`terraform/eks-infra/`](terraform/eks-infra) - Terraform stack for the VPC and EKS cluster (managed nodes + Fargate).
- [`.devcontainer/`](.devcontainer) - Dev Container definition with all required tooling.
- [`docs/`](docs) - project documentation (see below).

## Documentation

- [docs/development.md](docs/development.md) - dev container setup, Colima, AWS credentials via `.env`.
- [docs/app.md](docs/app.md) - the two PHP apps and how to run them locally with `docker compose`.
- [docs/infra.md](docs/infra.md) - Terraform stacks, why they're split, recommended apply / destroy order.

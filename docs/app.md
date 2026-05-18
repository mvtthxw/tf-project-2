# Applications

The [app/](../app) folder contains two small PHP demo applications. Both serve a single page over Apache and are intentionally tiny - they exist to prove that the EKS cluster, ECR repos and (eventually) Helm charts work end to end.

## Layout

```
app/
├── app-managed/
│   ├── .version
│   ├── Dockerfile
│   └── index.php
├── app-fargate/
│   ├── .version
│   ├── Dockerfile
│   └── index.php
├── build_and_push.py
└── docker-compose.yml
```

Each app is a self-contained directory with its own `.version` file, `Dockerfile` and `index.php`. Names match the ECR repository short names defined in [terraform/ecr/terraform.tfvars](../terraform/ecr/terraform.tfvars), so building and pushing stays straightforward.

## `app-managed`

A minimal "time" page. It prints:

- the app version (read from `/etc/app/version` inside the container),
- the container's hostname (so you can see which pod served the request when running on EKS),
- the current server time.

Source: [app/app-managed/index.php](../app/app-managed/index.php).

This app is intended to run on the **managed node group** side of the EKS cluster (hence the name).

## `app-fargate`

A minimal "param store" page. It prints:

- the app version (read from `/etc/app/version`),
- the container's hostname,
- the value of the `PARAMS_STORE` environment variable, or `<i>not set</i>` if it isn't defined.

Source: [app/app-fargate/index.php](../app/app-fargate/index.php).

This app is intended to run on the **Fargate** side of the EKS cluster, and the `PARAMS_STORE` value is a placeholder for a future SSM Parameter Store integration.

## Versioning

Each app has a `.version` file (e.g. `v1.0.0`) that is the **single source of truth** for the release version.

- **In the image** - the Dockerfile copies `.version` to `/etc/app/version` at build time.
- **In the UI** - both `index.php` files read `/etc/app/version` and display it in the page heading. If the file is missing (e.g. running PHP outside Docker), the fallback is `dev`.
- **In ECR** - [build_and_push.py](#build-and-push-to-ecr) reads the same `.version` file and uses it as the image tag.

To bump a version, edit `app/<app>/.version`, then rebuild locally (`docker compose up -d --build`) or push to ECR (`python3 build_and_push.py <app>`).

## Dockerfiles

Both apps use the same multistage build (kept identical on purpose):

1. Stage 1 (`ubuntu:latest`) - stages `index.php` into `/web/`.
2. Stage 2 (`php:8.3-apache`) - copies `index.php` into Apache's document root, copies `.version` to `/etc/app/version`, exposes port `80`, runs as the unprivileged `www-data` user.

Reference: [app/app-fargate/Dockerfile](../app/app-fargate/Dockerfile) (the `app-managed` Dockerfile is identical).

## Build and push to ECR

[app/build_and_push.py](../app/build_and_push.py) builds Docker images and pushes them to the matching ECR repositories. It is meant to be run from inside the dev container (see [docs/development.md](development.md)).

### Prerequisites

- The `terraform/ecr` stack has been applied (repositories must exist).
- Valid AWS credentials are available in the environment (via `~/Documents/.env` on the host - see [docs/development.md](development.md#aws-credentials-via-env)).
- `aws` and `docker` are on your PATH.

### Usage

```bash
cd app
python3 build_and_push.py                    # build and push both apps
python3 build_and_push.py app-managed        # one app only
python3 build_and_push.py app-fargate
```

### Configuration

Defaults mirror [terraform/ecr/terraform.tfvars](../terraform/ecr/terraform.tfvars). Override via environment variables or CLI flags:

| Source | Variable / flag | Default |
| ------ | --------------- | ------- |
| env / `--username` | `USERNAME` | `mvtthxw` |
| env / `--repo` | `REPO` | `k8s-php` |
| env / `--environment` | `ENVIRONMENT` | `dev` |
| env / `--region` | `REGION` | `us-east-1` |

ECR repository names follow the same convention as Terraform: `<username>-<repo>-<environment>-<app>` (e.g. `mvtthxw-k8s-php-dev-app-managed`).

### What the script does

1. Resolves the AWS account ID and ECR registry hostname via `aws sts get-caller-identity`.
2. Logs Docker in to ECR (`aws ecr get-login-password` piped to `docker login`).
3. For each app: reads `.version`, runs `docker build`, pushes **only** the `:<version>` tag (no `:latest`).
4. Disables BuildKit provenance and SBOM attestations (`--provenance=false`, `--sbom=false`) so each push creates exactly one image entry in ECR per version.

The version baked into `/etc/app/version` always matches the ECR tag.

### Bumping and pushing a new version

```bash
echo "v1.0.1" > app-managed/.version
python3 build_and_push.py app-managed
```

## Local smoke test with Docker Compose

[app/docker-compose.yml](../app/docker-compose.yml) wires both apps up so you can verify them in a browser before pushing anything to ECR or deploying to EKS:

| Service       | Host port | Container port |
| ------------- | --------- | -------------- |
| `app-managed` | `8081`    | `80`           |
| `app-fargate` | `8082`    | `80`           |

`PARAMS_STORE` is injected for `app-fargate` from the `environment:` block of the compose file, so the page has something to render locally.

### Run

```bash
cd app
docker compose up -d --build
```

Then open:

- <http://localhost:8081> -> `app-managed`
- <http://localhost:8082> -> `app-fargate`

The dev container forwards ports `8081` and `8082` automatically (see [docs/development.md](development.md#forwarded-ports)), so the URLs work from the host browser even when you're running compose inside the dev container.

### Iterate

After editing `index.php`, a `Dockerfile`, or `.version`, rebuild and restart:

```bash
docker compose up -d --build
```

A `.version` change is reflected in the page heading after rebuild, because the Dockerfile copies the file into the image.

### Stop

```bash
docker compose down
```

## Note on `PARAMS_STORE`

For local runs, `PARAMS_STORE` comes from `docker-compose.yml` (`PARAMS_STORE: "LOCAL VALUE"`). On AWS the variable will be supplied by a different mechanism (e.g. SSM Parameter Store via the Secrets Store CSI Driver), but the application code itself doesn't care - it just reads `getenv('PARAMS_STORE')`.

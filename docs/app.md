# Applications

The [app/](../app) folder contains two small PHP demo applications. Both serve a single page over Apache and are intentionally tiny - they exist to prove that the EKS cluster, ECR repos and (eventually) Helm charts work end to end.

## Layout

```
app/
├── app-managed/
│   ├── Dockerfile
│   └── index.php
├── app-fargate/
│   ├── Dockerfile
│   └── index.php
└── docker-compose.yml
```

Each app is a self-contained directory with its own `Dockerfile` and `index.php`. Names match the ECR repository short names defined in [terraform/ecr/terraform.tfvars](../terraform/ecr/terraform.tfvars), so building and pushing stays straightforward.

## `app-managed`

A minimal "time" page. It prints:

- the container's hostname (so you can see which pod served the request when running on EKS),
- the current server time.

Source: [app/app-managed/index.php](../app/app-managed/index.php).

This app is intended to run on the **managed node group** side of the EKS cluster (hence the name).

## `app-fargate`

A minimal "param store" page. It prints:

- the container's hostname,
- the value of the `PARAMS_STORE` environment variable, or `<i>not set</i>` if it isn't defined.

Source: [app/app-fargate/index.php](../app/app-fargate/index.php).

This app is intended to run on the **Fargate** side of the EKS cluster, and the `PARAMS_STORE` value is a placeholder for a future SSM Parameter Store integration.

## Dockerfiles

Both apps use the same multistage build (kept identical on purpose):

1. Stage 1 (`ubuntu:latest`) - stages `index.php` into `/web/`.
2. Stage 2 (`php:8.3-apache`) - copies `index.php` into Apache's document root, exposes port `80`, runs as the unprivileged `www-data` user.

A `VERSION` env variable is hard-coded in the image (`ENV VERSION=v1.0.0`).

Reference: [app/app-fargate/Dockerfile](../app/app-fargate/Dockerfile) (the `app-managed` Dockerfile is identical).

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

After editing `index.php` or a `Dockerfile`, rebuild and restart:

```bash
docker compose up -d --build
```

### Stop

```bash
docker compose down
```

## Note on `PARAMS_STORE`

For local runs, `PARAMS_STORE` comes from `docker-compose.yml` (`PARAMS_STORE: "LOCAL VALUE"`). On AWS the variable will be supplied by a different mechanism (e.g. SSM Parameter Store via the Secrets Store CSI Driver), but the application code itself doesn't care - it just reads `getenv('PARAMS_STORE')`.

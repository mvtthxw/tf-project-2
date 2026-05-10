# Development

This repository is set up to be opened inside a **Dev Container**. All required tooling (Terraform, AWS CLI, kubectl, Helm, PHP, Docker-in-Docker, GitHub CLI) is installed automatically by the container image, so you don't need to install anything locally except a code editor and a container runtime.

## Prerequisites

On the host machine you need:

- **VS Code** or **Cursor** with the [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension.
- A working **container runtime**:
  - **Docker Desktop** (macOS, Windows, Linux), or
  - **Colima** (lightweight alternative on macOS / Linux).

That's it. Everything else lives in the container.

## Container runtime: Colima

If you don't want to run Docker Desktop, Colima is the recommended alternative. It runs a small Linux VM with the Docker daemon inside.

### First-time start (sized VM)

The dev container builds Docker images and runs `terraform`, so give the VM enough resources:

```bash
colima start --cpu 6 --memory 16 --runtime docker
```

This creates a VM with 6 CPUs, 16 GB RAM and the Docker runtime. The settings are remembered, so on subsequent days you can just run `colima start`.

### Day-to-day commands

```bash
colima start          # boot the VM (uses the previously configured size)
colima stop           # shut it down to free host resources
colima status         # check whether it's running and how it's configured
colima delete         # destroy the VM completely (a.k.a. `colima rm`); use this for a clean reset
```

### Verifying the runtime

After `colima start`, confirm Docker can talk to it:

```bash
docker info
docker ps
```

If `docker info` reports a server, you're good to open the dev container.

## AWS credentials via `.env`

The dev container pulls AWS credentials from a `.env` file that **lives outside the repo**, on the host machine. This is configured in [.devcontainer/devcontainer.json](../.devcontainer/devcontainer.json):

```json
"runArgs": [
  "--env-file=${localEnv:HOME}/Documents/.env"
]
```

So before opening the container, create `~/Documents/.env` on the host with the variables AWS CLI / Terraform expect:

```dotenv
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
AWS_DEFAULT_REGION=us-east-1
# Optional, only when using temporary credentials (SSO / STS):
# AWS_SESSION_TOKEN=...
```

The file is read once at container start and the values are injected as environment variables inside the container. Keep it out of version control - it's intentionally outside the repo so it can never be committed by accident.

If you need to change credentials, edit `~/Documents/.env` and rebuild the container (`Dev Containers: Rebuild and Reopen in Container`).

## Opening the project in the dev container

1. Make sure your container runtime is up (`colima start` or Docker Desktop running).
2. Make sure `~/Documents/.env` exists with valid AWS credentials.
3. Open the repo folder in VS Code or Cursor.
4. Run the command **Dev Containers: Reopen in Container** (or **Rebuild and Reopen in Container** if it's the first time / after changing `devcontainer.json`).

After the container builds, a `postCreateCommand` runs and prints the versions of `terraform`, `kubectl`, `helm`, `php` and `docker` as a sanity check. If you see all five, the environment is ready.

## What's preinstalled in the container

Pulled from the `features` block of [.devcontainer/devcontainer.json](../.devcontainer/devcontainer.json):

- `git` and `gh` (GitHub CLI)
- `docker` (Docker-in-Docker, so you can build images and run `docker compose` inside the dev container)
- `terraform` 1.15.2
- `aws-cli` (latest)
- `kubectl` and `helm` (latest)
- `php` 8.3 with Composer

Plus a curated list of VS Code extensions (Terraform / HCL, YAML, Kubernetes, AWS Toolkit, Intelephense, PHP Debug, Prettier, EditorConfig).

## Forwarded ports

Two ports are forwarded automatically so the local PHP apps are reachable from the host browser:

- `8081` -> `app-managed`
- `8082` -> `app-fargate`

See [docs/app.md](app.md) for how to run the apps locally.

## Persistent Cursor state

The dev container mounts a named Docker volume `cursor-state-tf-project-2` at `/home/vscode/.cursor`. This keeps Cursor's chat history, plans and transcripts across container rebuilds - rebuilding the container won't wipe your conversation state.

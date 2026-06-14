# Development

This repository is set up to be opened inside a **Dev Container**. Core tooling (Terraform, AWS CLI, kubectl, Helm, PHP, Python, Docker-in-Docker, GitHub CLI) is installed by Dev Container features; extra Kubernetes tools (`k9s`, `kubectx`, `kubens`) and shell aliases are set up automatically by post-create scripts. You don't need to install anything locally except a code editor and a container runtime.

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

After the container builds, two lifecycle hooks run scripts from [.devcontainer/](../.devcontainer/):

| Hook | When | What it does |
|------|------|--------------|
| `postCreateCommand` | once, on first container create / rebuild | installs extra Kubernetes CLI tools, configures shell aliases |
| `postStartCommand` | on every container start | prints installed tool versions (health check) |

On rebuild, wait a few seconds after Cursor reconnects before using `kubens`, `kubectx` or `k9s` — `postCreateCommand` may still be downloading k9s (~120 MB). Faster tools (`kubectx`, `kubens`) are installed first; k9s comes last.

To check versions manually at any time:

```bash
bash .devcontainer/print-tool-versions.sh
```

If a tool is missing after rebuild, re-run the installer (idempotent — skips already installed binaries):

```bash
bash .devcontainer/install-k8s-tools.sh
bash .devcontainer/setup-shell.sh
source ~/.bashrc
```

## What's preinstalled in the container

### Core tooling (Dev Container features)

Pulled from the `features` block of [.devcontainer/devcontainer.json](../.devcontainer/devcontainer.json):

- `git` and `gh` (GitHub CLI)
- `python` 3.13 - used to run `app/build_and_push.py`
- `docker` (Docker-in-Docker with **Buildx** enabled, so you can build images and run `docker compose` inside the dev container)
- `terraform` 1.15.2
- `aws-cli` (latest)
- `kubectl` and `helm` (latest)
- `php` 8.3 with Composer

Plus a curated list of VS Code extensions (Terraform / HCL, YAML, Kubernetes, AWS Toolkit, Intelephense, PHP Debug, Prettier, EditorConfig).

### Extra Kubernetes CLI tools (post-create scripts)

`k9s`, `kubectx` and `kubens` are **not** installed via community Dev Container features (they proved unreliable). Instead, [.devcontainer/install-k8s-tools.sh](../.devcontainer/install-k8s-tools.sh) downloads and installs them on container create:

| Tool | Source | Notes |
|------|--------|-------|
| `kubectx` / `kubens` | [ahmetb/kubectx](https://github.com/ahmetb/kubectx) v0.9.5 (bash scripts) | installed first — ready within ~1 s |
| `k9s` | [derailed/k9s](https://github.com/derailed/k9s) GitHub release (binary) | installed last — large download, architecture-aware (amd64 / arm64) |

Binaries land in `/usr/local/bin` (or `~/.local/bin` as fallback if `sudo` is unavailable).

### Shell setup

[.devcontainer/setup-shell.sh](../.devcontainer/setup-shell.sh) adds a `source` line to `~/.bashrc` pointing at [.devcontainer/kubectl-aliases.sh](../.devcontainer/kubectl-aliases.sh). That file defines kubectl shortcuts (`k`, `kgp`, `kaf`, …) and aliases for the extra tools (`kctx` → `kubectx`, `kns` → `kubens`).

Open a **new terminal** (or run `source ~/.bashrc`) after the first container create to load the aliases.

### Dev container scripts

All scripts live in [.devcontainer/](../.devcontainer/):

| Script | Purpose |
|--------|---------|
| `install-k8s-tools.sh` | installs k9s, kubectx, kubens (idempotent) |
| `setup-shell.sh` | wires kubectl aliases into `~/.bashrc` (idempotent) |
| `print-tool-versions.sh` | prints versions of all key tools |
| `kubectl-aliases.sh` | kubectl / kubectx / kubens alias definitions (sourced by bashrc) |

## Typical workflow

A common session from zero to a running cluster:

1. Start the host runtime (`colima start` or Docker Desktop) and confirm `~/Documents/.env` has valid AWS credentials.
2. **Dev Containers: Reopen in Container**.
3. Smoke-test the apps locally:

   ```bash
   cd app
   docker compose up -d --build
   # http://localhost:8081 and http://localhost:8082
   ```

4. Apply the ECR stack and push images (see [docs/infra.md](infra.md)):

   ```bash
   cd terraform/ecr
   terraform apply

   cd ../../app
   python3 build_and_push.py
   ```

5. Apply the EKS infrastructure stack (VPC, cluster, Helm controllers):

   ```bash
   cd terraform/eks-infra
   terraform apply
   ```

   This step can take a while (cluster creation, node group, Helm releases). Timeouts are set to up to 45 minutes - do not interrupt the apply. See [docs/infra.md](infra.md) for the full recommended order and verification checklist.

See [docs/app.md](app.md) for versioning, compose details and the full `build_and_push.py` reference.

## Forwarded ports

Two ports are forwarded automatically so the local PHP apps are reachable from the host browser:

- `8081` -> `app-managed`
- `8082` -> `app-fargate`

See [docs/app.md](app.md) for how to run the apps locally.

## Persistent Cursor state

The dev container mounts a named Docker volume `cursor-state-tf-project-2` at `/home/vscode/.cursor`. This keeps Cursor's chat history, plans and transcripts across container rebuilds - rebuilding the container won't wipe your conversation state.

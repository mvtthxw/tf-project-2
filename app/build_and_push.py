#!/usr/bin/env python3
"""Build & push app images to ECR.

Version is read from each app's .version file. The same value is:
  - copied into the image at /etc/app/version (read by the PHP app)
  - used as the image tag in ECR (only the ":<version>" tag is pushed)

BuildKit provenance/SBOM attestations are disabled so each push results in
exactly one ECR image entry per version (no extra attestation manifests).

Configuration defaults must stay in sync with terraform/ecr/terraform.tfvars
(the ECR repo names are derived as: <username>-<repo>-<environment>-<short>).
"""

from __future__ import annotations

import argparse
import os
import shutil
import subprocess
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
ALL_APPS = ("app-managed", "app-fargate")

DEFAULTS = {
    "username": os.environ.get("USERNAME", "mvtthxw"),
    "repo": os.environ.get("REPO", "k8s-php"),
    "environment": os.environ.get("ENVIRONMENT", "dev"),
    "region": os.environ.get("REGION", "us-east-1"),
}


def parse_args() -> argparse.Namespace:
    """Parse CLI arguments for the build & push command.

    Reads positional `apps` (zero or more app names) and optional overrides
    for `--username`, `--repo`, `--environment`, `--region`. Defaults come
    from the matching env vars (see `DEFAULTS`), or from hardcoded values
    that mirror `terraform/ecr/terraform.tfvars`.

    Returns:
        Parsed `argparse.Namespace` with attributes:
        `apps` (list[str]), `username`, `repo`, `environment`, `region`.
    """
    parser = argparse.ArgumentParser(
        description=(
            "Build and push app images to ECR. "
            "Version comes from <app>/.version. Pushed tag: :<version>."
        ),
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=(
            "defaults (override via env vars or flags):\n"
            f"  USERNAME={DEFAULTS['username']}\n"
            f"  REPO={DEFAULTS['repo']}\n"
            f"  ENVIRONMENT={DEFAULTS['environment']}\n"
            f"  REGION={DEFAULTS['region']}\n"
        ),
    )
    parser.add_argument(
        "apps",
        nargs="*",
        help=f"apps to build (default: all of {', '.join(ALL_APPS)})",
    )
    parser.add_argument("--username", default=DEFAULTS["username"])
    parser.add_argument("--repo", default=DEFAULTS["repo"])
    parser.add_argument("--environment", default=DEFAULTS["environment"])
    parser.add_argument("--region", default=DEFAULTS["region"])
    return parser.parse_args()


def fail(msg: str) -> None:
    """Print an error message to stderr and abort with exit code 1.

    Args:
        msg: Human-readable error description (printed prefixed with `ERROR:`).

    Exits:
        Always calls `sys.exit(1)`; never returns.
    """
    print(f"ERROR: {msg}", file=sys.stderr)
    sys.exit(1)


def require_command(cmd: str) -> None:
    """Ensure an external command is available in PATH.

    Args:
        cmd: Name of the executable to look for (e.g. `aws`, `docker`).

    Exits:
        Calls `fail()` (exit 1) if the command is not found in PATH.
    """
    if shutil.which(cmd) is None:
        fail(f"required command not found in PATH: {cmd}")


def run(cmd: list[str]) -> None:
    """Echo and execute a shell command, streaming its output to the terminal.

    Args:
        cmd: Command and its arguments as a list (e.g. `["docker", "push", uri]`).

    Raises:
        subprocess.CalledProcessError: If the command exits with a non-zero status
            (caught at the top level in `__main__` and turned into a friendly error).
    """
    print("    $ " + " ".join(cmd), flush=True)
    subprocess.run(cmd, check=True)


def capture(cmd: list[str]) -> str:
    """Run a command and return its stdout (stripped of trailing whitespace).

    Used for capturing values like the AWS account ID or the ECR password
    without printing them to the terminal.

    Args:
        cmd: Command and its arguments as a list.

    Returns:
        The command's stdout, with leading/trailing whitespace removed.

    Raises:
        subprocess.CalledProcessError: If the command exits with a non-zero status.
    """
    return subprocess.run(cmd, check=True, capture_output=True, text=True).stdout.strip()


def read_version(app_dir: Path) -> str:
    """Read and validate the `.version` file inside an app directory.

    Args:
        app_dir: Path to the app folder (must contain a non-empty `.version` file).

    Returns:
        The version string, stripped of whitespace (e.g. `"v1.0.0"`).

    Exits:
        Calls `fail()` (exit 1) if `.version` is missing or empty.
    """
    version_file = app_dir / ".version"
    if not version_file.is_file():
        fail(f"missing version file: {version_file}")
    version = version_file.read_text().strip()
    if not version:
        fail(f"empty version file: {version_file}")
    return version


def docker_login(registry: str, region: str) -> None:
    """Authenticate the local Docker client against an ECR registry.

    Pulls a short-lived password via `aws ecr get-login-password` and pipes it
    into `docker login` over stdin (so the secret never appears in argv or logs).

    Args:
        registry: Full ECR registry hostname (e.g. `123.dkr.ecr.us-east-1.amazonaws.com`).
        region: AWS region used for the `get-login-password` call.

    Raises:
        subprocess.CalledProcessError: If either AWS or Docker login fails.
    """
    password = capture(["aws", "ecr", "get-login-password", "--region", region])
    print(f"    $ aws ecr get-login-password --region {region} | docker login ...")
    subprocess.run(
        ["docker", "login", "--username", "AWS", "--password-stdin", registry],
        input=password,
        text=True,
        check=True,
        capture_output=True,
    )


def build_and_push(app: str, version: str, registry: str, args: argparse.Namespace) -> None:
    """Build a single app image and push it to ECR with the `:version` tag.

    The ECR repository name is composed as
    `<username>-<repo>-<environment>-<app>` (matching `terraform/ecr/ecr.tf`).
    BuildKit provenance/SBOM attestations are disabled (`--provenance=false`,
    `--sbom=false`) to avoid extra `<untagged>` manifests in ECR.

    Args:
        app: Short app name matching the directory under `app/` (e.g. `"app-managed"`).
        version: Version string to bake into the image and use as the tag.
        registry: Full ECR registry hostname.
        args: Parsed CLI namespace (uses `username`, `repo`, `environment`).

    Raises:
        subprocess.CalledProcessError: If `docker build` or `docker push` fails.
    """
    app_dir = SCRIPT_DIR / app
    ecr_name = f"{args.username}-{args.repo}-{args.environment}-{app}"
    ecr_uri = f"{registry}/{ecr_name}"

    print()
    print("=" * 60)
    print(f" {app} -> {ecr_uri}:{version}")
    print("=" * 60)

    print("==> Building")
    run([
        "docker", "build",
        "--provenance=false",
        "--sbom=false",
        "--tag", f"{ecr_uri}:{version}",
        str(app_dir),
    ])

    print(f"==> Pushing :{version}")
    run(["docker", "push", f"{ecr_uri}:{version}"])

    print(f"==> Done: {ecr_uri}:{version}")


def main() -> int:
    """Orchestrate the full build & push flow.

    Steps:
        1. Parse CLI arguments and resolve the list of apps to process.
        2. Validate app names and required commands (`aws`, `docker`).
        3. Resolve the AWS account ID and ECR registry hostname.
        4. Authenticate Docker against ECR.
        5. For each app: read its `.version`, build the image, push both tags.

    Returns:
        Process exit code (0 on success).

    Exits:
        Calls `fail()` (exit 1) on validation errors (unknown app, missing
        directory, missing/empty `.version`, missing `aws`/`docker`).
    """
    args = parse_args()
    apps = args.apps or list(ALL_APPS)

    unknown = [a for a in apps if a not in ALL_APPS]
    if unknown:
        fail(f"unknown app(s): {', '.join(unknown)}. Allowed: {', '.join(ALL_APPS)}")

    require_command("aws")
    require_command("docker")

    for app in apps:
        if not (SCRIPT_DIR / app).is_dir():
            fail(f"app directory not found: {SCRIPT_DIR / app}")

    print("==> Resolving AWS account / ECR registry")
    account_id = capture([
        "aws", "sts", "get-caller-identity", "--query", "Account", "--output", "text",
    ])
    registry = f"{account_id}.dkr.ecr.{args.region}.amazonaws.com"
    print(f"    account:  {account_id}")
    print(f"    region:   {args.region}")
    print(f"    registry: {registry}")

    print("==> Logging in to ECR")
    docker_login(registry, args.region)

    for app in apps:
        version = read_version(SCRIPT_DIR / app)
        build_and_push(app, version, registry, args)

    print()
    print("All done.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

# cachekit-io/runner — Custom GitHub Actions runner image
# Bakes in build tooling that doesn't change per-job to cut CI time.
#
# What's baked in (stable across jobs):
#   - build-essential, pkg-config, libssl-dev (system build deps)
#   - uv (Python package manager)
#   - Rust stable + rustfmt, clippy
#   - Python 3.9–3.14 (pre-installed via uv)
#
# What stays in workflow (changes per-repo):
#   - uv sync (project-specific deps)
#   - Rust/Python venv caches (via actions/cache)

ARG RUNNER_VERSION=2.332.0
FROM ghcr.io/actions/actions-runner:${RUNNER_VERSION}

# System build dependencies (as root)
USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    pkg-config \
    libssl-dev \
    cmake \
    && rm -rf /var/lib/apt/lists/*

# Install uv (system-wide)
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv
COPY --from=ghcr.io/astral-sh/uv:latest /uvx /usr/local/bin/uvx

# Switch to runner user for Rust and Python installs
USER runner

# Install Rust stable with rustfmt + clippy
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- \
    -y \
    --default-toolchain stable \
    --profile minimal \
    --component rustfmt,clippy

ENV PATH="/home/runner/.cargo/bin:${PATH}"

# Pre-install Python versions (3.9–3.14)
RUN uv python install 3.9 3.10 3.11 3.12 3.13 3.14

# Verify everything works
RUN cc --version \
    && pkg-config --version \
    && uv --version \
    && rustc --version \
    && cargo --version \
    && rustfmt --version \
    && cargo clippy --version \
    && uv python list --only-installed

LABEL org.opencontainers.image.source="https://github.com/cachekit-io/runner"
LABEL org.opencontainers.image.description="Custom GitHub Actions runner for cachekit-io CI/CD"

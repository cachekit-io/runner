# cachekit-io/runner

Custom GitHub Actions runner image for [cachekit-io](https://github.com/cachekit-io) CI/CD.

Bakes in build tooling that doesn't change per-job, cutting minutes off every CI run.

## What's baked in

| Tool | Purpose |
|------|---------|
| `build-essential`, `pkg-config`, `libssl-dev` | System build deps (C linker, OpenSSL headers) |
| `uv` | Python package manager (eliminates `setup-uv` action) |
| Rust stable + `rustfmt`, `clippy` | Rust toolchain (eliminates `dtolnay/rust-toolchain`) |
| Python 3.9–3.14 | Pre-installed via `uv` (eliminates `uv python install`) |

## What stays in workflows

- `uv sync` — project-specific Python deps
- `actions/cache` — Rust target dir, Python venv (change per-commit)

## Usage

In your workflow:

```yaml
runs-on: cachekit  # ARC runner scale set label
```

In `values-cachekit-runner-set.yaml`:

```yaml
containers:
  - name: runner
    image: ghcr.io/cachekit-io/runner:latest
```

## Building

Push a tag to build and publish:

```bash
git tag v1.0.0
git push origin v1.0.0
```

Image is pushed to `ghcr.io/cachekit-io/runner`.

## Updating

When base tools need updating (new Rust stable, new Python minor):

1. Update `Dockerfile`
2. Tag a new version
3. Update the image reference in `values-cachekit-runner-set.yaml`
4. `helm upgrade` the runner scale set

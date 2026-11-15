---
name: python-shell-environments
displayName: Python Shell Environments
description: Use when running Python from the shell and package availability is uncertain; prefer `uv run --with ...` for one-off dependencies, fall back to a project-local virtual environment or an intentional shared fallback when needed. Do not use when the task is not shell-based Python work or when the project already provides a dedicated runtime path.
version: 1.0.0
metadata:
  category: Development
  tags:
    - python
    - uv
    - shell
    - venv
---

# Python Shell Environments

## Overview

Use this skill when a shell command needs Python plus packages that may or may not already exist. The default is an isolated, ephemeral `uv run --with ...` command. Do not install packages globally for the user.

## Workflow

1. Classify the need before running Python.
   - If the task is a one-off script or inspection, use `uv run --with ...`.
   - If the project already has a `pyproject.toml` and managed dependencies, prefer `uv run ...` inside that project.
   - If the work will be repeated in the same repo and needs installed packages, use a virtual environment instead of global installs.
2. Use the preferred environment order.
   - First choice: `uv run --with ...`
   - Second choice: project-local virtual environment such as `.venv`
   - Third choice: shared fallback environment at `~/.jabali/python/venv`
3. Keep commands isolated.
   - Add only the packages needed for the current command.
   - Prefer pinned or narrow package specs when version drift matters.
   - Keep the Python invocation and its dependencies in one shell command when practical.
4. Validate the result.
   - Run the actual script or import check.
   - Confirm the command succeeded without installing globally.
   - Read logs or stderr before ending the task.
5. Treat the shared fallback as a last resort.
   - Use `~/.jabali/python/venv` only when a reusable cross-task environment is intentionally required.
   - Recreate it when dependency state is unclear, imports fail unexpectedly, or package drift would affect the task.
   - Avoid it for one-off commands and any task that should remain isolated to the current repo.

## Preferred Patterns

### One-off command

Use `uv run --with ...`:

```bash
uv run --with pillow python -c "from PIL import Image; print(Image.__version__)"
```

```bash
uv run --with "httpx>=0.27,<0.28" python -c "import httpx; print(httpx.__version__)"
```

### Project-managed command

If the repo already uses `uv` and has a `pyproject.toml`, run inside that project:

```bash
uv run python -c "import sys; print(sys.version)"
```

```bash
uv run --group dev pytest
```

### Project-local virtual environment

If the task needs a reusable environment in the repo:

```bash
uv venv .venv
. .venv/bin/activate
uv pip install pillow
python script.py
```

### Shared fallback virtual environment

Use only when a project-local environment is not appropriate and the shared state is intentional:

```bash
uv venv ~/.jabali/python/venv
. ~/.jabali/python/venv/bin/activate
uv pip install pillow
python script.py
```

Recreate the shared venv when package versions drift, imports break, or a previous task left it in an unknown state.

## Do Not Do

- Do not run `python3 -m pip install ...` against the global interpreter.
- Do not run `pip install ...` without confirming it targets an isolated environment.
- Do not use `sudo pip install`.
- Do not assume the system Python should be mutated for one task.
- Do not create a shared environment when `uv run --with ...` is enough.

## Selection Rules

1. Choose `uv run --with ...` when:
   - the command is one-off
   - the dependency set is small
   - nothing needs to persist after the command finishes
2. Choose `uv run ...` without `--with` when:
   - the repo already declares the dependencies
   - the task should use the project's locked environment
3. Choose a project-local `.venv` when:
   - the same repo will run multiple Python commands
   - the work benefits from a persistent environment
   - the task may add packages not yet declared in the repo
4. Choose `~/.jabali/python/venv` only when:
   - there is no suitable project directory for a local venv
   - the work still needs isolation from the global interpreter

## Quick Checks

- Check whether `pyproject.toml` already exists before inventing a new environment.
- Check whether the command can be expressed as one `uv run --with ...` line before creating a venv.
- Check import success or package version explicitly when environment state is in doubt.

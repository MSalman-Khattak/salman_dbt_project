# AGENTS.md

## Project overview

This repository is a minimal Python project initialized with `uv`. It is intentionally lightweight and currently centered around a small executable entry point in `main.py`.

The repo should stay simple unless a clear requirement justifies adding dependencies, tooling, or project structure.

## Working conventions

- Use Python 3.11+ as the baseline.
- Prefer `uv` for package management and execution commands instead of `pip`.
- Keep dependencies explicit in `pyproject.toml`.
- Prefer small, focused changes over broad refactors.
- Update `README.md` when commands, workflow, or project behavior change.
- Do not introduce extra frameworks or build systems unless the task clearly requires them.

## Common commands

- Install dependencies: `uv sync`
- Run the app: `uv run python main.py`
- Add a package: `uv add <package-name>`
- Run tests (when present): `uv run pytest`
- Run a single script: `uv run python <path/to/script.py>`

## Code expectations

- Keep scripts and modules readable and explicit.
- Favor straightforward Python idioms over clever abstractions.
- If a feature grows beyond a small script, split it into purposeful modules rather than adding hidden complexity.
- Preserve compatibility with the project’s current Python version and dependency constraints.

## Repo-specific notes

- The current workspace is a minimal scaffold, not yet a full dbt project or data pipeline implementation.
- If this repository later evolves into a dbt-focused workflow, add the relevant dbt conventions and tooling in a way that complements the existing lightweight structure instead of replacing it.
- When changing project structure, keep the entry points and developer workflow easy to discover from the root files.

# Agent Guidelines

These instructions apply to the entire repository unless a more specific `AGENTS.md` overrides them.

## Quality gates
- Always run `ruff check .` and `pytest` before committing. Fix or document any failures before pushing.
- Prefer typed Python. Every new public function should have full type annotations.

## Commit messages
- Use short, imperative sentences (e.g., `feat: add resume schema`).
- Mention the scope of the change in the subject line; keep it under 72 characters.

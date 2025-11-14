# Infrastructure Guidelines

Scope: `infra/`.

- Prefer Docker Compose for multi-service definitions; keep service names aligned with application folders (e.g., `backend`, `bot`).
- Format YAML with two spaces per indent and place environment variables under an explicit `environment:` section.
- Store secrets in `.env` files that are excluded from git, and load them via `env_file` references.
- Document every exposed port and network in comments above the corresponding block.

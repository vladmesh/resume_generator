# Resume Generator

Resume Generator is a multi-service platform that helps users assemble polished CVs using a FastAPI backend and a Telegram bot companion. The repository already contains the Python packages for both services and a placeholder `infra/` folder for container definitions.

## Architecture
```
Telegram User ──> Bot (apps/bot) ──> Backend API (apps/backend) ──> PostgreSQL
          ^                                           |
          └────────────────────── Notification/Webhook┘
```
- **Bot** – guides candidates through a conversational flow, collects structured answers, and forwards them to the backend.
- **Backend** – exposes REST endpoints for resume storage, template rendering, and webhook callbacks back to the bot.
- **Database** – PostgreSQL (via `asyncpg`/SQLAlchemy) persists resumes, templates, and chat sessions.

## Tech stack
| Layer | Technology |
| --- | --- |
| Backend | FastAPI, Pydantic, SQLAlchemy, asyncpg |
| Bot | python-telegram-bot, asyncio |
| Tooling | pytest, ruff, uvicorn |
| Infrastructure | Docker, Docker Compose (planned in `infra/`) |

## Containers
The platform is designed to run three containers orchestrated through `infra/docker-compose.yml`:
1. `backend` – serves the FastAPI app via `uvicorn apps.backend.server:app`.
2. `bot` – runs the Telegram bot entry point `python -m apps.bot.bot`.
3. `postgres` – stores application data; the backend connects via `DATABASE_URL`.

Once the Compose definition is added you can build and start all services with:
```bash
docker compose -f infra/docker-compose.yml up --build
```
Each service exposes health endpoints (`/health` for the backend and the bot's internal check) that Compose can use for healthchecks.

## Development workflow
1. Create a virtual environment and install dependencies: `python -m venv .venv && source .venv/bin/activate && pip install -e .[dev]`.
2. Export the required environment variables (`TELEGRAM_TOKEN`, `DATABASE_URL`, etc.).
3. Run formatters/linters: `ruff check .`.
4. Start the backend locally: `uvicorn apps.backend.server:app --reload --port 8000`.
5. Start the bot in another terminal: `python -m apps.bot.bot`.
6. Execute tests: `pytest`.

## Git hooks
The repository ships with a `hooks/pre-push` script that mirrors the CI gates by running `ruff check .` and `pytest`. Install or update it locally with one of the following commands:

```bash
cp hooks/pre-push .git/hooks/pre-push
# or create a symlink so updates are picked up automatically
ln -sf ../../hooks/pre-push .git/hooks/pre-push
```

The hook must be executable (`chmod +x hooks/pre-push`) and will block pushes until both commands succeed.

## Production runbook
Until full IaC is added, you can launch the services manually:
```bash
# Backend
uvicorn apps.backend.server:app --host 0.0.0.0 --port 8000

# Bot (needs TELEGRAM_TOKEN in the environment)
python -m apps.bot.bot
```
When `infra/docker-compose.yml` becomes available, prefer `docker compose -f infra/docker-compose.yml up -d backend bot postgres` to produce a reproducible deployment.

## Test suite
- Unit/integration tests: `pytest`
- Static analysis: `ruff check .`

Both commands should succeed (or known failures must be documented) before any pull request is opened.

## Repository layout
- [`apps/bot`](apps/bot): Telegram bot code that communicates with users.
- [`apps/backend`](apps/backend): FastAPI application exposing resume generation APIs.
- [`infra`](infra): Deployment and infrastructure configuration (currently instructions only).
- [`tests`](tests): Automated tests (to be added).
- [`scripts`](scripts): Utility scripts for local development (planned).

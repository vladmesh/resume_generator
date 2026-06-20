# Resume Generator

> **Status: early scaffold / WIP.** This is a project skeleton, not a working product. The backend exposes only a `/health` endpoint (the module is a stub) and the Telegram bot entry point raises `NotImplementedError`. The sections below separate what exists today from the intended design.

A planned multi-service tool to assemble CVs via a FastAPI backend and a Telegram bot. The repo currently holds the package layout for both services, infra compose files, and local tooling.

## What works today
- **Backend** (`apps/backend/server.py`): a FastAPI app with a single `/health` endpoint returning `{"status": "ok"}`. No resume, template, or persistence endpoints yet.
- **Bot** (`apps/bot/bot.py`): entry-point stub; `run_bot()` raises `NotImplementedError`.
- **Tests** (`tests/`): a `/health` test plus import smoke tests (`pytest`).
- **Infra** (`infra/`): Docker Compose files for dev/prod/test and a Caddy config.
- **Tooling**: `ruff` config, `scripts/manage.sh`, and a `hooks/pre-push` git hook.

## Planned architecture (not built yet)
```
Telegram User ──> Bot (apps/bot) ──> Backend API (apps/backend) ──> PostgreSQL
          ^                                           |
          └────────────────────── Notification/Webhook┘
```
- **Bot** – guide candidates through a conversational flow and forward answers to the backend.
- **Backend** – REST endpoints for resume storage, template rendering, and webhook callbacks.
- **Database** – PostgreSQL (`asyncpg`/SQLAlchemy) for resumes, templates, and sessions.

## Tech stack (target)
| Layer | Technology |
| --- | --- |
| Backend | FastAPI, Pydantic, SQLAlchemy, asyncpg |
| Bot | python-telegram-bot, asyncio |
| Tooling | pytest, ruff, uvicorn |
| Infrastructure | Docker, Docker Compose, Caddy |

## Development
1. Create a venv and install: `python -m venv .venv && source .venv/bin/activate && pip install -e .[dev]`.
2. Lint: `ruff check .`
3. Run the backend stub: `uvicorn apps.backend.server:app --reload --port 8000` (only `/health` responds).
4. Tests: `pytest`.

Compose files for dev/prod/test live in `infra/` (they build the current stubs).

## Git hooks
`hooks/pre-push` runs `ruff check .` and `pytest` before each push. There is no remote CI configured yet. Install:
```bash
ln -sf ../../hooks/pre-push .git/hooks/pre-push && chmod +x hooks/pre-push
```

## Repository layout
- [`apps/backend`](apps/backend): FastAPI app — currently a `/health` stub.
- [`apps/bot`](apps/bot): Telegram bot entry point — stub (`NotImplementedError`).
- [`infra`](infra): Docker Compose (dev/prod/test) + Caddy config.
- [`tests`](tests): health + import tests.
- [`scripts`](scripts): `manage.sh` dev helper.

## License
MIT

# Resume Generator

Resume Generator is a platform that helps users assemble polished CVs using a FastAPI backend and a Telegram bot companion.

## Structure
- [`apps/bot`](apps/bot): Telegram bot code that communicates with users.
- [`apps/backend`](apps/backend): FastAPI application that exposes resume generation APIs.
- [`infra`](infra): Deployment and infrastructure configuration (TBD).
- [`scripts`](scripts): Utility scripts for local development (TBD).
- [`tests`](tests): Automated tests.

## Development
1. Install dependencies: `pip install -e .[dev]`
2. Run formatters and linters: `ruff check .`
3. Start the backend: `uvicorn apps.backend.server:app --reload`
4. Run the bot entry point: `python -m apps.bot.bot`
5. Execute tests: `pytest`

## Roadmap
- [ ] Implement resume data models and persistence layer.
- [ ] Build conversational flows for the Telegram bot.
- [ ] Add CI pipelines and deployment scripts.

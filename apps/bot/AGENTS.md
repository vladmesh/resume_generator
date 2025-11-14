# Bot Guidelines

Scope: `apps/bot`.

- Treat the bot as an asynchronous application: prefer `async def` handlers and never block the event loop. Offload blocking work to executors.
- Keep user-facing copy centralized in constants to simplify localisation.
- All interactions with external services must go through a dedicated client module so that they can be mocked in tests.
- When adding configuration, read it from environment variables via `pydantic-settings`-style helpers instead of hard-coding secrets.

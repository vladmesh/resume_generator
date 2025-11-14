# Backend Guidelines

Scope: `apps/backend`.

- Organise endpoints with `APIRouter` instances per domain. Avoid putting business logic directly inside route functions.
- Every request/response pair must use explicit Pydantic models; never return raw dictionaries.
- Use dependency injection helpers to pass database sessions or clients instead of relying on globals.
- Raise `HTTPException` with meaningful status codes for error paths; never `return` error dicts manually.

"""FastAPI backend stub."""

from fastapi import FastAPI

app = FastAPI(title="Resume Generator API")


@app.get("/health")
async def healthcheck() -> dict[str, str]:
    """Simple healthcheck endpoint."""
    raise NotImplementedError("Backend is not implemented yet.")

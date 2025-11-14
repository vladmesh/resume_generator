"""FastAPI backend stub."""

from fastapi import FastAPI
from pydantic import BaseModel


class HealthResponse(BaseModel):
    """Schema describing the API health payload."""

    status: str


app = FastAPI(title="Resume Generator API")


@app.get("/health", response_model=HealthResponse)
async def healthcheck() -> HealthResponse:
    """Simple healthcheck endpoint."""
    return HealthResponse(status="ok")

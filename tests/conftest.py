"""Shared pytest fixtures for the project."""

import sys
from collections.abc import Iterator
from pathlib import Path

import pytest
from fastapi.testclient import TestClient

PROJECT_ROOT = Path(__file__).resolve().parents[1]
if str(PROJECT_ROOT) not in sys.path:
    sys.path.append(str(PROJECT_ROOT))

from apps.backend.server import app  # noqa: E402


@pytest.fixture()
def api_client() -> Iterator[TestClient]:
    """Provide a FastAPI test client instance for API tests."""

    with TestClient(app) as client:
        yield client

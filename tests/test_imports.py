"""Sanity checks ensuring main packages import correctly."""


def test_backend_server_import() -> None:
    """The backend application should be importable and expose the FastAPI app."""

    from apps.backend import server

    assert server.app.title == "Resume Generator API"


def test_backend_package_is_namespace() -> None:
    """The backend package should behave like a regular namespace package."""

    import apps.backend as backend

    assert hasattr(backend, "__path__")

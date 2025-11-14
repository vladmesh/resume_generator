FROM python:3.11-slim AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8000

WORKDIR /app

RUN apt-get update \
    && apt-get install --no-install-recommends -y build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY pyproject.toml README.md ./

RUN pip install --upgrade pip \
    && pip install --no-cache-dir \
        fastapi \
        SQLAlchemy \
        asyncpg \
        "uvicorn[standard]" \
        gunicorn

COPY apps ./apps

EXPOSE 8000

CMD [\
    "gunicorn", "apps.backend.server:app", \
    "-k", "uvicorn.workers.UvicornWorker", \
    "-b", "0.0.0.0:8000", \
    "--workers", "4", \
    "--timeout", "60"
]

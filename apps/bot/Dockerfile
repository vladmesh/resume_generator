FROM python:3.11-slim AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

RUN apt-get update \
    && apt-get install --no-install-recommends -y build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY pyproject.toml README.md ./

RUN pip install --upgrade pip \
    && pip install --no-cache-dir \
        python-telegram-bot \
        fastapi \
        SQLAlchemy \
        asyncpg

COPY apps ./apps

CMD ["python", "-c", "from apps.bot.bot import run_bot; run_bot()"]

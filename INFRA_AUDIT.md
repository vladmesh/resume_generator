# Docker Infrastructure Audit

**Дата аудита:** 2024-12-06  
**Статус:** Средний - структура хорошая, но есть критичные проблемы

---

## Обзор

Проект имеет хорошую базовую структуру с разделением на apps и infra. Это единственный проект с `.dockerignore` - молодцы! Однако есть проблемы в Dockerfile, которые увеличивают размер образов.

---

## Положительные стороны

- Есть `.dockerignore` - единственный проект с ним
- Чёткая структура директорий (apps/, infra/)
- Разделение окружений (dev, prod, test)

---

## Выявленные проблемы

### 1. build-essential остаётся в runtime образе (КРИТИЧНО)

**Текущий код (apps/backend/Dockerfile):**
```dockerfile
FROM python:3.11-slim AS runtime

RUN apt-get update \
    && apt-get install --no-install-recommends -y build-essential \  # ~200MB!
    && rm -rf /var/lib/apt/lists/*
```

**Проблема:** `build-essential` нужен только для компиляции Python пакетов с C-расширениями. В финальном образе он не нужен и занимает ~200MB.

**Решение:** Использовать multi-stage build:

```dockerfile
# Build stage
FROM python:3.11-slim AS builder

RUN apt-get update && \
    apt-get install --no-install-recommends -y build-essential && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY pyproject.toml README.md ./

RUN pip install --upgrade pip && \
    pip wheel --no-cache-dir --wheel-dir=/wheels \
        fastapi SQLAlchemy asyncpg "uvicorn[standard]" gunicorn

# Runtime stage
FROM python:3.11-slim AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8000

WORKDIR /app

# Только установка wheels, без build-essential
COPY --from=builder /wheels /wheels
RUN pip install --no-cache-dir /wheels/* && rm -rf /wheels

COPY apps ./apps

EXPOSE 8000

CMD ["gunicorn", "apps.backend.server:app", \
    "-k", "uvicorn.workers.UvicornWorker", \
    "-b", "0.0.0.0:8000", \
    "--workers", "4", \
    "--timeout", "60"]
```

---

### 2. Зависимости хардкожены в Dockerfile

**Текущий код:**
```dockerfile
RUN pip install --no-cache-dir \
    fastapi \
    SQLAlchemy \
    asyncpg \
    "uvicorn[standard]" \
    gunicorn
```

**Проблемы:**
- Нет версий - непредсказуемые сборки
- Не используется pyproject.toml
- При добавлении зависимости нужно править Dockerfile

**Решение:** Использовать requirements.txt или pyproject.toml:

```dockerfile
COPY pyproject.toml poetry.lock* ./
RUN pip install poetry && \
    poetry export -f requirements.txt --output requirements.txt && \
    pip install -r requirements.txt
```

Или проще:
```dockerfile
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
```

---

### 3. Volume mount в docker-compose.dev.yml слишком широкий

**Текущий код:**
```yaml
backend:
  volumes:
    - ../:/app  # Весь проект!
```

**Проблема:** Монтируется весь проект включая:
- `.git/`
- `infra/`
- Другие apps

**Решение:**
```yaml
backend:
  volumes:
    - ../apps/backend:/app/apps/backend
    - ../pyproject.toml:/app/pyproject.toml:ro
```

---

### 4. Ruff контейнер в docker-compose.dev.yml

**Текущий код:**
```yaml
ruff:
  image: ghcr.io/astral-sh/ruff:latest  # Всегда latest
  command: ["ruff", "check", "."]
```

**Проблемы:**
- `latest` тег - непредсказуемое поведение
- Контейнер запускается и сразу останавливается

**Решение:**
```yaml
ruff:
  image: ghcr.io/astral-sh/ruff:0.8.0  # Фиксированная версия
  profiles: ["lint"]  # Запускать только по требованию
  command: ["ruff", "check", "--fix", "."]
```

Использование:
```bash
docker compose --profile lint run ruff
```

---

### 5. Можно улучшить `.dockerignore`

**Текущий файл хороший, но можно дополнить:**

```gitignore
# Добавить к существующему:

# Docker
docker-compose*.yml
Dockerfile*

# Infra (не нужно в backend/bot образах)
infra/

# Documentation
*.md
!README.md

# Tests (для production образов)
tests/
*_test.py
test_*.py
conftest.py
```

---

## Рекомендуемые изменения

### Шаг 1: Исправить Dockerfile backend (20 минут)

Использовать multi-stage build без build-essential в runtime.

### Шаг 2: Создать requirements.txt или использовать poetry (15 минут)

```bash
# Если есть pyproject.toml с poetry
cd apps/backend
poetry export -f requirements.txt --output requirements.txt --without-hashes
```

### Шаг 3: Обновить docker-compose.dev.yml (10 минут)

Уточнить volume mounts и зафиксировать версию ruff.

### Шаг 4: Дополнить .dockerignore (5 минут)

Добавить исключения для infra/ и тестов.

---

## Ожидаемый результат

| Метрика | До | После |
|---------|-----|-------|
| Размер образа backend | ~450MB | ~250MB |
| Время сборки | ~2 мин | ~1.5 мин |
| Воспроизводимость сборки | Низкая | Высокая |

---

## Приоритет исправлений

1. **ВЫСОКИЙ:** Убрать build-essential из runtime - экономия ~200MB
2. **ВЫСОКИЙ:** Версионировать зависимости - воспроизводимость
3. **СРЕДНИЙ:** Уточнить volume mounts - безопасность и производительность
4. **НИЗКИЙ:** Улучшить .dockerignore - небольшая оптимизация

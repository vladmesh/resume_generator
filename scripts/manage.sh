#!/usr/bin/env bash
set -euo pipefail

COMPOSE_DEV_FILE="infra/docker-compose.dev.yml"

usage() {
  cat <<'USAGE'
Usage: scripts/manage.sh <command>

Commands:
  start_dev     Start the development stack defined in infra/docker-compose.dev.yml.
  stop_dev      Stop the development stack and remove volumes.
  restart_dev   Restart the development stack.
  test_backend  Execute pytest inside the backend container.
  test_bot      Run ruff checks inside the bot container.
USAGE
}

require_compose_file() {
  if [[ ! -f "$COMPOSE_DEV_FILE" ]]; then
    echo "Expected Compose file '$COMPOSE_DEV_FILE' not found." >&2
    exit 1
  fi
}

require_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    echo "docker is not installed or not on PATH." >&2
    exit 1
  fi
}

ensure_dev_stack() {
  require_docker
  require_compose_file
  docker compose -f "$COMPOSE_DEV_FILE" up -d "$@"
}

start_dev() {
  ensure_dev_stack
}

stop_dev() {
  require_docker
  require_compose_file
  docker compose -f "$COMPOSE_DEV_FILE" down -v
}

restart_dev() {
  stop_dev
  start_dev
}

exec_backend() {
  docker compose -f "$COMPOSE_DEV_FILE" exec backend /bin/sh -c "pip install --upgrade pip >/dev/null && pip install -e .[dev] >/dev/null && pytest"
}

exec_bot() {
  docker compose -f "$COMPOSE_DEV_FILE" exec bot /bin/sh -c "pip install --upgrade pip >/dev/null && pip install -e .[dev] >/dev/null && ruff check apps/bot"
}

if [[ $# -lt 1 ]]; then
  usage >&2
  exit 1
fi

case "$1" in
  start_dev)
    start_dev
    ;;
  stop_dev)
    stop_dev
    ;;
  restart_dev)
    restart_dev
    ;;
  test_backend)
    ensure_dev_stack backend
    exec_backend
    ;;
  test_bot)
    ensure_dev_stack bot
    exec_bot
    ;;
  -h|--help|help)
    usage
    ;;
  *)
    echo "Unknown command: $1" >&2
    usage >&2
    exit 1
    ;;
esac

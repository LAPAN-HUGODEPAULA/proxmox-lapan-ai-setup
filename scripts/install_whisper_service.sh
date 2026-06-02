#!/usr/bin/env bash
set -Eeuo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
live_compose="${AI_COMPOSE_DIR:-/srv/ai/compose/core}"
env_file="${live_compose}/.env"

"${repo_root}/scripts/deploy_ai_stack.sh"

docker_cmd=(docker)
if ! docker info >/dev/null 2>&1; then
  docker_cmd=(sudo docker)
fi

echo "Pulling and starting Speaches Whisper service..."
"${docker_cmd[@]}" compose --env-file "${env_file}" -f "${live_compose}/docker-compose.yml" pull speaches
"${docker_cmd[@]}" compose --env-file "${env_file}" -f "${live_compose}/docker-compose.yml" up -d speaches

echo "Waiting for Speaches health endpoint..."
for _ in {1..60}; do
  if curl -fsS http://127.0.0.1:8000/health >/dev/null 2>&1; then
    echo "Speaches is healthy at http://127.0.0.1:8000"
    exit 0
  fi
  sleep 2
done

echo "Speaches did not become healthy within 120 seconds. Check logs:" >&2
echo "  ${docker_cmd[*]} compose --env-file ${env_file} -f ${live_compose}/docker-compose.yml logs --tail=100 speaches" >&2
exit 1

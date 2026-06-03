#!/usr/bin/env bash
set -Eeuo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
live_compose="${AI_COMPOSE_DIR:-/srv/ai/compose/core}"
env_file="${live_compose}/.env"

"${repo_root}/scripts/deploy_ai_stack.sh"

set -a
# shellcheck disable=SC1090
source "${env_file}"
set +a

docker_cmd=(docker)
if ! docker info >/dev/null 2>&1; then
  docker_cmd=(sudo docker)
fi

speaches_auth_args=()
if [[ -n "${SPEACHES_API_KEY:-}" ]]; then
  speaches_auth_args=(-H "Authorization: Bearer ${SPEACHES_API_KEY}")
fi

echo "Pulling and starting Speaches Whisper service..."
"${docker_cmd[@]}" compose --env-file "${env_file}" -f "${live_compose}/docker-compose.yml" pull speaches
"${docker_cmd[@]}" compose --env-file "${env_file}" -f "${live_compose}/docker-compose.yml" up -d speaches

echo "Waiting for Speaches health endpoint..."
for _ in {1..60}; do
  if curl -fsS "${speaches_auth_args[@]}" http://127.0.0.1:8000/health >/dev/null 2>&1; then
    echo "Speaches is healthy at http://127.0.0.1:8000"
    break
  fi
  sleep 2
done

if ! curl -fsS "${speaches_auth_args[@]}" http://127.0.0.1:8000/health >/dev/null 2>&1; then
  echo "Speaches did not become healthy within 120 seconds. Check logs:" >&2
  echo "  ${docker_cmd[*]} compose --env-file ${env_file} -f ${live_compose}/docker-compose.yml logs --tail=100 speaches" >&2
  exit 1
fi

echo "Ensuring Speaches model is downloaded: ${SPEACHES_MODEL}"
if ! curl -fsS "${speaches_auth_args[@]}" http://127.0.0.1:8000/v1/models | grep -F "${SPEACHES_MODEL}" >/dev/null; then
  curl -fsS -X POST "${speaches_auth_args[@]}" "http://127.0.0.1:8000/v1/models/${SPEACHES_MODEL}" >/dev/null
fi

echo "Waiting for Speaches model registry..."
for _ in {1..300}; do
  if curl -fsS "${speaches_auth_args[@]}" http://127.0.0.1:8000/v1/models | grep -F "${SPEACHES_MODEL}" >/dev/null; then
    echo "Speaches model is available: ${SPEACHES_MODEL}"
    exit 0
  fi
  sleep 2
done

echo "Speaches model was not listed within 600 seconds. Check model download logs:" >&2
echo "  ${docker_cmd[*]} compose --env-file ${env_file} -f ${live_compose}/docker-compose.yml logs --tail=200 speaches" >&2
exit 1

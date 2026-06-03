#!/usr/bin/env bash
set -Eeuo pipefail

stamp="$(date -u +%Y%m%d-%H%M%S)"
out="vm-state-${stamp}.txt"

docker_cmd=(docker)
if ! docker info >/dev/null 2>&1; then
  docker_cmd=(sudo docker)
fi

speaches_auth_args=()
if [[ -f /srv/ai/compose/core/.env ]]; then
  set -a
  # shellcheck disable=SC1091
  source /srv/ai/compose/core/.env
  set +a
  if [[ -n "${SPEACHES_API_KEY:-}" ]]; then
    speaches_auth_args=(-H "Authorization: Bearer ${SPEACHES_API_KEY}")
  fi
fi

{
  echo "# Ubuntu AI VM state collection"
  echo "# Date: $(date -u --iso-8601=seconds)"
  echo
  echo "## OS"
  cat /etc/os-release || true
  echo
  echo "## Kernel"
  uname -a || true
  echo
  echo "## CPU flags of interest"
  grep -m1 '^flags' /proc/cpuinfo | grep -Eo '\b(avx2|avx|fma|bmi1|bmi2|abm|movbe|pclmulqdq)\b' | sort -u || true
  echo
  echo "## Filesystems"
  df -h || true
  echo
  echo "## Mounts"
  findmnt /srv/ai || true
  findmnt / || true
  echo
  echo "## Block devices"
  lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINTS || true
  echo
  echo "## Swap"
  swapon --show || true
  free -h || true
  echo
  echo "## NVIDIA"
  lspci -nn | grep -Ei 'nvidia|10de' || true
  nvidia-smi || true
  echo
  echo "## Docker"
  "${docker_cmd[@]}" version || true
  "${docker_cmd[@]}" info --format 'Docker Root Dir: {{.DockerRootDir}}' || true
  echo
  echo "## Compose stack"
  "${docker_cmd[@]}" compose --env-file /srv/ai/compose/core/.env -f /srv/ai/compose/core/docker-compose.yml ps || true
  echo
  echo "## Service smoke tests"
  curl -fsS http://127.0.0.1:11434/api/tags || true
  echo
  curl -fsS "${speaches_auth_args[@]}" http://127.0.0.1:8000/health || true
  echo
  curl -fsS "${speaches_auth_args[@]}" http://127.0.0.1:8000/v1/models || true
  echo
  echo
  echo "## Listening ports"
  ss -tlnp || true
} | tee "${out}"

echo "Wrote ${out}"

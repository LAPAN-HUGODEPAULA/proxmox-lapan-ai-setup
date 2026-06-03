#!/usr/bin/env bash
set -Eeuo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
live_root="${AI_ROOT:-/srv/ai}"
live_compose="${AI_COMPOSE_DIR:-/srv/ai/compose/core}"
env_file="${live_compose}/.env"

skip_graph_bootstrap="${SKIP_GRAPH_BOOTSTRAP:-0}"

require_file() {
  local path="$1"
  [[ -f "${path}" ]] || { echo "Missing required file: ${path}" >&2; exit 1; }
}

set -a
# shellcheck disable=SC1090
source "${env_file}"
set +a

require_file "${repo_root}/configs/ai-stack/rag/research-platform.yaml"
require_file "${repo_root}/configs/ai-stack/agents/policies/default.yaml"

mkdir -p \
  "${live_root}/agents/audit" \
  "${live_root}/agents/coding" \
  "${live_root}/agents/graphs" \
  "${live_root}/agents/papers" \
  "${live_root}/agents/clinical" \
  "${live_root}/agents/scratch" \
  "${live_root}/agents/policies" \
  "${live_root}/rag/benchmarks" \
  "${live_root}/rag/configs" \
  "${live_root}/rag/pipelines" \
  "${live_root}/rag/rerankers" \
  "${live_root}/zotero/exports" \
  "${live_root}/zotero/pdfs"

install -m 0644 "${repo_root}/configs/ai-stack/rag/research-platform.yaml" "${live_root}/rag/configs/research-platform.yaml"
install -m 0644 "${repo_root}/configs/ai-stack/agents/policies/default.yaml" "${live_root}/agents/policies/default.yaml"

if [[ "${skip_graph_bootstrap}" != "1" ]]; then
  echo "Applying Qdrant collection: ${RAG_COLLECTION}"
  qdrant_create_out="$(mktemp)"
  trap 'rm -f "${qdrant_create_out}"' EXIT
  qdrant_create_status="$(
    curl -sS -o "${qdrant_create_out}" -w '%{http_code}' -X PUT \
      -H "api-key: ${QDRANT_API_KEY}" \
      -H "Content-Type: application/json" \
      "http://127.0.0.1:6333/collections/${RAG_COLLECTION}" \
      -d '{"vectors":{"size":1024,"distance":"Cosine"},"on_disk_payload":true}'
  )"
  if [[ "${qdrant_create_status}" != "200" && "${qdrant_create_status}" != "201" && "${qdrant_create_status}" != "409" ]]; then
    cat "${qdrant_create_out}" >&2
    echo "Failed to create or verify Qdrant collection ${RAG_COLLECTION}" >&2
    exit 1
  fi

  neo4j_password="${NEO4J_AUTH#neo4j/}"
  echo "Applying Neo4j constraints"
  curl -fsS -u "neo4j:${neo4j_password}" \
    -H "Content-Type: application/json" \
    -X POST "http://127.0.0.1:7474/db/neo4j/tx/commit" \
    -d '{
      "statements": [
        {"statement":"CREATE CONSTRAINT paper_id IF NOT EXISTS FOR (p:Paper) REQUIRE p.doc_id IS UNIQUE"},
        {"statement":"CREATE CONSTRAINT chunk_id IF NOT EXISTS FOR (c:Chunk) REQUIRE c.chunk_id IS UNIQUE"},
        {"statement":"CREATE CONSTRAINT concept_name IF NOT EXISTS FOR (c:Concept) REQUIRE c.name IS UNIQUE"}
      ]
    }' >/dev/null
else
  echo "Skipping Qdrant and Neo4j bootstrap because SKIP_GRAPH_BOOTSTRAP=1"
fi

touch "${live_root}/rag/benchmarks/.gitkeep"
touch "${live_root}/agents/audit/.gitkeep"

echo "Research platform scaffold installed."

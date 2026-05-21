# Compose Stack

### 1. Objective & Prerequisites

- Deploy the local AI service stack with Docker Compose.
- Required previous state: Docker installed, NVIDIA runtime working, `/srv/ai` mounted.
- Estimated time: 15-30 minutes excluding model downloads. Risk level: medium.

### 2. Step-by-Step Execution

**Step 1: Prepare environment file**
- **Purpose:** Keep secrets and image tags outside Compose YAML.
- **Command(s):**
```bash
cd /srv/ai/compose/core
cp .env.example .env
vim .env
```
- **Explanation:** Replace every placeholder with local secrets.
- **Expected Output:**
```text
No output on successful edit.
```
- **Verification:** `.env` exists and is not committed to Git.
- **⚠️ Caveats/Traps:** Never commit real `WEBUI_SECRET_KEY`, `QDRANT_API_KEY`, `NEO4J_AUTH`, or `JUPYTER_TOKEN`.

**Step 2: Use the validated Jupyter base tag variable**
- **Purpose:** Keep the Jupyter build reproducible and aligned with the current user-selected image tag.
- **Command(s):**
```bash
grep -R 'JUPYTER_BASE_TAG' .env docker-compose.yml jupyter/Dockerfile
```
- **Expected Output:**
```text
.env:JUPYTER_BASE_TAG=2026-05-11
docker-compose.yml:        JUPYTER_BASE_TAG: ${JUPYTER_BASE_TAG}
jupyter/Dockerfile:ARG JUPYTER_BASE_TAG=2026-05-11
```
- **Verification:** The older date-tag variable name should no longer appear in active configuration.
- **⚠️ Caveats/Traps:** A mismatched build arg silently falls back to the Dockerfile default.

**Step 3: Start services**
- **Purpose:** Run Ollama, Open WebUI, Qdrant, Neo4j, and JupyterLab.
- **Command(s):**
```bash
cd /srv/ai/compose/core
sudo docker compose build
sudo docker compose up -d
sudo docker compose ps
```
- **Explanation:** Services use bind mounts under `/srv/ai` and ports bound to `127.0.0.1`.
- **Expected Output:**
```text
NAME         STATUS
ollama       Up
open-webui   Up
qdrant       Up
neo4j        Up
jupyter      Up
```
- **Verification:** `sudo docker compose ps` shows all services up.
- **⚠️ Caveats/Traps:** Current user is not in the Docker group; use `sudo docker`.

### 3. Configuration Files

Required `.env` keys:

```env
TZ=America/Sao_Paulo
OLLAMA_TAG=latest
OPEN_WEBUI_TAG=main
QDRANT_TAG=latest
NEO4J_TAG=2026.04.0
JUPYTER_BASE_TAG=2026-05-11
UV_VERSION=latest

WEBUI_SECRET_KEY=${REPLACE_WITH_RANDOM_HEX}
QDRANT_API_KEY=${REPLACE_WITH_RANDOM_HEX}
NEO4J_AUTH=neo4j/${REPLACE_WITH_STRONG_PASSWORD}
JUPYTER_TOKEN=${REPLACE_WITH_RANDOM_TOKEN}
```

Jupyter Dockerfile base:

```dockerfile
ARG JUPYTER_BASE_TAG=2026-05-11
FROM quay.io/jupyter/minimal-notebook:${JUPYTER_BASE_TAG}
```

### 4. Troubleshooting & Recovery

- If Compose cannot build Jupyter, verify that `JUPYTER_BASE_TAG` is used consistently.
- If Docker says permission denied, run `sudo docker ...`.
- If Qdrant returns `401`, include the `api-key` header.
- If Open WebUI cannot reach Ollama, verify both are on the same Compose network and `OLLAMA_BASE_URL=http://ollama:11434`.

# Compose Stack

### 1. Objective & Prerequisites

- Deploy Ollama, Open WebUI, Qdrant, Neo4j, and JupyterLab as a local Docker Compose stack.
- Required previous state: Docker and NVIDIA Container Toolkit working; `/srv/ai` mounted.
- Estimated time: 20-40 minutes plus image download time. Risk level: medium.

### 2. Step-by-Step Execution

**Step 1: Install Compose files**
- **Purpose:** Put runtime Compose configuration under `/srv/ai/compose/core`.
- **Command(s):**
```bash
mkdir -p /srv/ai/compose/core
cp -a configs/ai-stack/docker-compose.yml /srv/ai/compose/core/docker-compose.yml
cp -a configs/ai-stack/jupyter /srv/ai/compose/core/jupyter
cp configs/ai-stack/.env.example /srv/ai/compose/core/.env
vim /srv/ai/compose/core/.env
chmod 600 /srv/ai/compose/core/.env
```
- **Explanation:** Real secrets live in `.env`; only `.env.example` is committed.
- **Expected Output:**
```text
No output on success.
```
- **Verification:** `test -f /srv/ai/compose/core/.env && test -f /srv/ai/compose/core/docker-compose.yml`.
- **⚠️ Caveats/Traps:** Replace every placeholder before starting services.

**Step 2: Build and start services**
- **Purpose:** Launch the local AI service stack.
- **Command(s):**
```bash
cd /srv/ai/compose/core
sudo docker compose build
sudo docker compose up -d
sudo docker compose ps
```
- **Explanation:** Jupyter is built locally; other services are pulled from configured image tags.
- **Expected Output:**
```text
NAME        IMAGE                       STATUS
ollama      ollama/ollama:...           Up ...
open-webui  ghcr.io/open-webui/...      Up ...
qdrant      qdrant/qdrant:...           Up ...
neo4j       neo4j:...                   Up ...
jupyter     core-jupyter:...            Up ...
```
- **Verification:** `sudo docker compose ps` -> All services up or healthy.
- **⚠️ Caveats/Traps:** If Jupyter build fails due to Polars CPU warnings, verify VM CPU type is `host`.

### 3. Configuration Files

- `configs/ai-stack/docker-compose.yml`
- `configs/ai-stack/.env.example`
- `configs/ai-stack/jupyter/Dockerfile`

### 4. Troubleshooting & Recovery

- If service pulls fill disk, verify `/srv/ai` and Docker root.
- If Open WebUI cannot reach Ollama, check `OLLAMA_BASE_URL=http://ollama:11434`.
- If Neo4j fails, inspect `sudo docker logs neo4j` and validate `NEO4J_AUTH`.
- If Qdrant rejects requests, include the configured API key.

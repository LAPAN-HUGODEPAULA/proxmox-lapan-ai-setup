# Model Management

### 1. Objective & Prerequisites

- Pull and manage local models without filling storage.
- Required previous state: Ollama container running; `/srv/ai` has enough free space.
- Estimated time: variable. Risk level: medium due to disk growth.

### 2. Step-by-Step Execution

**Step 1: Check capacity before pulling**
- **Purpose:** Avoid repeating the storage exhaustion incident.
- **Command(s):**
```bash
df -h /srv/ai
sudo docker exec -it ollama ollama list
```
- **Explanation:** Models are stored under the Ollama volume, mapped to `/srv/ai/ollama`.
- **Expected Output:**
```text
Filesystem Size Used Avail Use% Mounted on
...
```
- **Verification:** At least tens of GB free before pulling large models.
- **⚠️ Caveats/Traps:** Model downloads can expand VM backing storage on Proxmox; host storage must also be healthy.

**Step 2: Pull initial models**
- **Purpose:** Install a small starting set for coding, general research, and embeddings.
- **Command(s):**
```bash
sudo docker exec -it ollama ollama pull qwen3:8b
sudo docker exec -it ollama ollama pull qwen2.5-coder:7b
sudo docker exec -it ollama ollama pull bge-m3
sudo docker exec -it ollama ollama pull embeddinggemma
```
- **Explanation:** Keep the initial set small until retrieval pipelines and backups are validated.
- **Expected Output:**
```text
pulling manifest
pulling ...
success
```
- **Verification:** `sudo docker exec -it ollama ollama list` -> Shows the downloaded models.
- **⚠️ Caveats/Traps:** Do not download many models before storage and backup policy are established.

### 3. Configuration Files

Ollama volume mapping in Compose:

```yaml
volumes:
  - /srv/ai/ollama:/root/.ollama
```

### 4. Troubleshooting & Recovery

- Remove unused model: `sudo docker exec -it ollama ollama rm ${MODEL_NAME}`.
- If pull fails mid-way, check free space and retry.
- If `/` fills, verify Docker root and `/srv/ai` mount.

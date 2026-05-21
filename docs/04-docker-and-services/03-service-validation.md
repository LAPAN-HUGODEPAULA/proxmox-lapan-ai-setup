# Service Validation

### 1. Objective & Prerequisites

- Verify that the Docker AI stack is running and locally reachable.
- Required previous state: Compose stack started.
- Estimated time: 10 minutes. Risk level: low.

### 2. Step-by-Step Execution

**Step 1: Run stack validation script**
- **Purpose:** Test the main services and GPU-enabled containers from one place.
- **Command(s):**
```bash
scripts/validate_stack.sh
```
- **Explanation:** The script checks Compose state, Docker root, NVIDIA SMI, container GPU access, and local service ports.
- **Expected Output:**
```text
## Compose status
NAME ... STATUS
## Docker root
Docker Root Dir: /srv/ai/docker
## GPU from container
+--- NVIDIA-SMI ...
```
- **Verification:** Every section completes without command failure.
- **⚠️ Caveats/Traps:** Run from a shell with access to `sudo docker`; do not expose ports externally to make validation pass.

**Step 2: Verify localhost bindings**
- **Purpose:** Confirm services are not exposed broadly.
- **Command(s):**
```bash
ss -tlnp | grep -E '11434|3000|6333|6334|7474|7687|8888'
```
- **Explanation:** Host-side service ports should be bound to `127.0.0.1`.
- **Expected Output:**
```text
LISTEN ... 127.0.0.1:11434 ...
LISTEN ... 127.0.0.1:3000 ...
...
```
- **Verification:** No AI service binds to `0.0.0.0` unless explicitly approved.
- **⚠️ Caveats/Traps:** Docker internal bridge listeners are expected; focus on published host ports.

### 3. Configuration Files

No files are modified in this phase.

### 4. Troubleshooting & Recovery

- If Ollama API fails, inspect `sudo docker logs ollama`.
- If GPU container fails, recheck NVIDIA Container Toolkit.
- If Open WebUI returns login/setup page, that is normal on first launch.
- If Jupyter requires token, use `JUPYTER_TOKEN` from `.env`.

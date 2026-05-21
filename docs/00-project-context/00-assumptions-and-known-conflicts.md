# Assumptions and Known Conflicts


> Status policy: this guide documents the current accepted target as Ubuntu Server 26.04 LTS. Any command output not yet re-collected after the final working state is marked `[MISSING]` and should be replaced after running `scripts/gather_host_state.sh` and `scripts/gather_vm_state.sh`.


### 1. Objective & Prerequisites

- This file records what is accepted as true, what has been validated, and what still needs fresh terminal output.
- Required previous state: repository created and uploaded.
- Estimated time: 5 minutes. Risk level: none.

### 2. Step-by-Step Execution

**Step 1: Confirm the target OS version**
- **Purpose:** Avoid mixing obsolete Ubuntu 24.04 notes with the accepted Ubuntu 26.04 working system.
- **Command(s):**
```bash
cat /etc/os-release
```
- **Explanation:** Run this inside the Ubuntu VM. The final documentation should use the real PRETTY_NAME and VERSION_CODENAME reported by the VM.
- **Expected Output:**
```text
PRETTY_NAME="Ubuntu 26.04 LTS"
VERSION_CODENAME=${UBUNTU_CODENAME}
```
- **Verification:** `grep -E "PRETTY_NAME|VERSION_CODENAME" /etc/os-release` -> What to look for to confirm success.
- **⚠️ Caveats/Traps:** Do not rewrite commands for another Ubuntu release unless the running VM confirms it.


**Step 2: Confirm the current phase status**
- **Purpose:** Prevent outdated roadmap statements from becoming canonical documentation.
- **Command(s):**
```bash
cd /srv/ai/compose/core
sudo docker compose ps
```
- **Explanation:** This verifies whether the Phase 4 Docker stack is actually running.
- **Expected Output:**
```text
NAME          IMAGE                         STATUS
ollama        ollama/ollama:...             Up ...
open-webui    ghcr.io/open-webui/...        Up ...
qdrant        qdrant/qdrant:...             Up ...
neo4j         neo4j:...                     Up ...
jupyter       ...                           Up ...
```
- **Verification:** `sudo docker compose ps` -> What to look for to confirm success.
- **⚠️ Caveats/Traps:** If any service is exited or restarting, Phase 4 should be documented as partially complete, not complete.


### 3. Configuration Files

No configuration files are applied in this phase.

### 4. Troubleshooting & Recovery

- If Ubuntu reports a different version, update every `26.04` reference before publishing.
- If Compose services are not running, use [Service Validation](../04-docker-and-services/03-service-validation.md) before updating the roadmap.
- If old docs contradict current state, preserve them under `archive/` and document only verified state in `docs/`.

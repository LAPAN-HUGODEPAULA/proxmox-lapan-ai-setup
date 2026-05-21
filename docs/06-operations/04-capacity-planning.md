# Capacity Planning

### 1. Objective & Prerequisites

- Estimate storage, RAM, and VRAM needs for the local AI stack.
- Required previous state: service stack defined.
- Estimated time: 15 minutes. Risk level: low.

### 2. Step-by-Step Execution

**Step 1: Track disk growth points**
- **Purpose:** Avoid both Proxmox host and Ubuntu VM space exhaustion.
- **Command(s):**
```bash
# Proxmox host
pvesm status
df -h /

# Ubuntu VM
df -h / /srv/ai
sudo docker system df
sudo du -sh /srv/ai/ollama /srv/ai/docker /srv/ai/qdrant /srv/ai/neo4j 2>/dev/null
```
- **Explanation:** AI storage grows in VM disks, Docker layers, Ollama models, vector indexes, and graph databases.
- **Expected Output:**
```text
[MISSING] Current capacity report.
```
- **Verification:** Keep root filesystems below 80% during normal operation.
- **⚠️ Caveats/Traps:** Thin-provisioned VM disks can fill the host even when the guest still appears healthy.

### 3. Configuration Files

No configuration files are modified.

### 4. Troubleshooting & Recovery

- If Proxmox `local` fills, move VM disks to proper storage.
- If `/srv/ai` fills, remove unused Ollama models and prune Docker caches.
- If RAM pressure appears, lower Neo4j memory or reduce concurrent workloads.

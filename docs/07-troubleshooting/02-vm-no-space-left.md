# VM: No Space Left on Device

### 1. Objective & Prerequisites

- Provide focused recovery steps for a known failure mode.
- Required previous state: access to either Proxmox host shell or Ubuntu VM shell, as specified.
- Estimated time: variable. Risk level: medium to high.

### 2. Step-by-Step Execution

**Step 1: Stop Docker**
- **Purpose:** Prevent further writes while diagnosing the full filesystem.
- **Command(s):**
```bash
sudo systemctl stop docker docker.socket containerd
```
- **Explanation:** Docker and Ollama are common sources of rapid disk growth.
- **Expected Output:**
```text
No output on success.
```
- **Verification:** `systemctl is-active docker` -> Not active.
- **⚠️ Caveats/Traps:** Do not prune blindly before identifying whether data should be preserved.

**Step 2: Identify the full mount**
- **Purpose:** Determine whether `/` or `/srv/ai` is full.
- **Command(s):**
```bash
df -h
du -xhd1 / 2>/dev/null | sort -h
du -sh /var/lib/docker /srv/ai /var/tmp /tmp 2>/dev/null
findmnt /srv/ai || true
```
- **Explanation:** If `/srv/ai` is not mounted, AI data may have been written into root.
- **Expected Output:**
```text
[MISSING] Filesystem usage report.
```
- **Verification:** `findmnt /srv/ai` -> Must show the large AI disk.
- **⚠️ Caveats/Traps:** If `/srv/ai` is just a directory on `/`, stop all model downloads.

**Step 3: Free emergency space**
- **Purpose:** Restore login and package manager functionality.
- **Command(s):**
```bash
sudo apt clean
sudo journalctl --vacuum-size=200M
sudo rm -rf /tmp/* /var/tmp/*
df -h /
```
- **Explanation:** These safe cleanups can restore enough space for corrective work.
- **Expected Output:**
```text
Filesystem ... Avail ... /
```
- **Verification:** Root has free space.
- **⚠️ Caveats/Traps:** Remove Ollama models only if you accept re-downloading them.

### 3. Configuration Files

Docker daemon should contain:

```json
{
  "data-root": "/srv/ai/docker"
}
```

### 4. Troubleshooting & Recovery

- If Docker root is `/var/lib/docker`, migrate it to `/srv/ai/docker`.
- If `/srv/ai` is not mounted, mount the data disk and move old root-backed data.
- If the VM cannot log in, use recovery mode or Proxmox console after host space is fixed.

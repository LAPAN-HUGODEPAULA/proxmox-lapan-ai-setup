# VM Filesystem Layout

### 1. Objective & Prerequisites

- Mount the AI data disk at `/srv/ai`, create a swap file, and keep Docker data off `/`.
- Required previous state: Ubuntu VM booted and the second virtual disk visible.
- Estimated time: 20-40 minutes. Risk level: high if the wrong disk is formatted.

### 2. Step-by-Step Execution

**Step 1: Inspect disks**
- **Purpose:** Identify the empty AI data disk before formatting.
- **Command(s):**
```bash
lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINTS
df -h
```
- **Explanation:** The target disk should be the dedicated large virtual disk, not the OS disk.
- **Expected Output:**
```text
${AI_DISK}  500G  disk
```
- **Verification:** `${AI_DISK}` has no mounted partitions and is the expected size.
- **⚠️ Caveats/Traps:** Formatting the wrong disk destroys data.

**Step 2: Create `/srv/ai` filesystem**
- **Purpose:** Put AI data, models, databases, and Docker storage on the large disk.
- **Command(s):**
```bash
sudo parted ${AI_DISK} --script mklabel gpt
sudo parted ${AI_DISK} --script mkpart ai-data ext4 1MiB 100%
sudo mkfs.ext4 -m 0 -L ai-data ${AI_PARTITION}
sudo mkdir -p /srv/ai
sudo blkid ${AI_PARTITION}
sudo vim /etc/fstab
sudo mount -a
```
- **Explanation:** `-m 0` avoids reserving 5% of a data-only filesystem for root.
- **Expected Output:**
```text
/srv/ai mounted from ${AI_PARTITION}
```
- **Verification:** `findmnt /srv/ai && df -h /srv/ai` -> Shows the large AI filesystem.
- **⚠️ Caveats/Traps:** Use UUID in `/etc/fstab`, not `/dev/vdb1`, because device names can change.

**Step 3: Create service directories**
- **Purpose:** Standardize persistent service paths.
- **Command(s):**
```bash
sudo mkdir -p /srv/ai/{compose,ollama,open-webui,qdrant,neo4j,jupyter,ingest,rag,zotero,models,backups,secrets,logs,docker}
sudo mkdir -p /srv/ai/qdrant/storage
sudo mkdir -p /srv/ai/neo4j/{data,logs,import,plugins,conf}
sudo mkdir -p /srv/ai/jupyter/work
sudo chown -R "$USER:$USER" /srv/ai
chmod 700 /srv/ai/secrets
```
- **Explanation:** Ownership allows the admin user to maintain Compose files while services write to bind-mounted paths.
- **Expected Output:**
```text
No output on success.
```
- **Verification:** `ls -ld /srv/ai /srv/ai/secrets` -> `/srv/ai` owned by user; secrets mode `700`.
- **⚠️ Caveats/Traps:** Do not start Docker before `/srv/ai` is mounted.

**Step 4: Add swap file**
- **Purpose:** Provide emergency memory without a swap partition.
- **Command(s):**
```bash
sudo fallocate -l ${SWAP_SIZE} /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
echo 'vm.swappiness=10' | sudo tee /etc/sysctl.d/99-ai-vm-swappiness.conf
sudo sysctl --system
```
- **Explanation:** Swap is a safety net, not a substitute for RAM.
- **Expected Output:**
```text
Setting up swapspace version 1, size = ...
```
- **Verification:** `swapon --show` -> Shows `/swapfile`.
- **⚠️ Caveats/Traps:** Heavy swapping during LLM inference indicates insufficient RAM or too-large models.

### 3. Configuration Files

`/etc/fstab` line:

```text
UUID=${AI_DISK_UUID} /srv/ai ext4 defaults,noatime 0 2
/swapfile none swap sw 0 0
```

### 4. Troubleshooting & Recovery

- If `/srv/ai` is not mounted, do not pull models or start Docker.
- If root fills, check whether `/srv/ai` was only a directory on `/`.
- If `mount -a` fails, check UUID and filesystem type in `/etc/fstab`.

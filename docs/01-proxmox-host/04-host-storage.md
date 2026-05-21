# Host Storage

### 1. Objective & Prerequisites

- Ensure VM disks are not placed on root-backed `local` storage when they can grow beyond the Proxmox root filesystem.
- Required previous state: Proxmox host booted and SSH accessible.
- Estimated time: 30-90 minutes. Risk level: high.

### 2. Step-by-Step Execution

**Step 1: Inspect storage layout**
- **Purpose:** Determine whether VM disks are on `local`, `local-lvm`, or another storage backend.
- **Command(s):**
```bash
df -h
pvesm status
pvs
vgs
lvs -a -o lv_name,vg_name,lv_size,lv_attr,origin,data_percent,metadata_percent,devices
qm config ${VMID} | grep -E 'scsi|virtio|sata|ide'
```
- **Explanation:** `local` is commonly a directory under `/var/lib/vz`; large qcow2 images there can fill `/`.
- **Expected Output:**
```text
Name         Type     Status ...
local        dir      active ...
[MISSING] local-lvm or alternative VM storage status
```
- **Verification:** `qm config ${VMID}` -> VM disks should not remain on root-backed `local` for large AI workloads.
- **⚠️ Caveats/Traps:** Do not delete files under `/var/lib/vz/images`; they may be VM disks.

**Step 2: Free emergency root space if needed**
- **Purpose:** Restore enough space for Proxmox services and migration commands.
- **Command(s):**
```bash
apt clean
journalctl --vacuum-size=200M
rm -f /var/tmp/pve-reserved-ports.tmp.*
rm -rf /tmp/*
df -h /
```
- **Explanation:** These are low-risk cleanups for package cache, journal logs, and temporary files.
- **Expected Output:**
```text
Filesystem                 Size  Used Avail Use% Mounted on
/dev/mapper/...root         ...  ...   ...  ...  /
```
- **Verification:** `df -h /` -> Root must have free space before continuing.
- **⚠️ Caveats/Traps:** Do not remove `/var/lib/vz/images/${VMID}` unless the VM is intentionally being destroyed.

**Step 3: Move VM disks to proper storage**
- **Purpose:** Prevent sparse qcow2 growth from filling the Proxmox root filesystem.
- **Command(s):**
```bash
qm stop ${VMID}
qm disk move ${VMID} scsi0 ${TARGET_STORAGE} --delete 1
qm disk move ${VMID} scsi1 ${TARGET_STORAGE} --delete 1
```
- **Explanation:** `${TARGET_STORAGE}` should be a storage backend with sufficient capacity, such as `local-lvm` or a dedicated VM datastore.
- **Expected Output:**
```text
transferred ...
removing old disk image ...
```
- **Verification:** `qm config ${VMID} | grep -E 'scsi0|scsi1'` -> Disks should reference `${TARGET_STORAGE}`.
- **⚠️ Caveats/Traps:** Ensure `${TARGET_STORAGE}` has enough available capacity before moving a 500 GB virtual disk.

### 3. Configuration Files

Proxmox storage definitions live in:

```text
/etc/pve/storage.cfg
```

Do not edit storage definitions blindly. Prefer `pvesm add ...` commands when creating new storage.

### 4. Troubleshooting & Recovery

- Error `unable to write /var/tmp/pve-reserved-ports...`: root filesystem is full; run emergency cleanup.
- `pvesm status` shows only `local`: inspect LVM; a thin pool may exist but not be configured.
- `qm disk move` syntax rejected: try `qm move_disk ${VMID} scsi0 ${TARGET_STORAGE} --delete 1`.
- Migration fails for lack of space: add or create a larger storage backend before moving disks.

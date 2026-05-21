# Proxmox Console: No Space Left on Device

### 1. Objective & Prerequisites

- Provide focused recovery steps for a known failure mode.
- Required previous state: access to either Proxmox host shell or Ubuntu VM shell, as specified.
- Estimated time: variable. Risk level: medium to high.

### 2. Step-by-Step Execution

**Step 1: Confirm host root is full**
- **Purpose:** Distinguish Proxmox host exhaustion from VM filesystem exhaustion.
- **Command(s):**
```bash
df -h
df -ih
pvesm status
```
- **Explanation:** Error paths such as `/var/tmp/pve-reserved-ports.tmp.*` indicate Proxmox host root exhaustion.
- **Expected Output:**
```text
/dev/mapper/...root  ...  100% /
```
- **Verification:** `df -h /` -> Shows root usage.
- **⚠️ Caveats/Traps:** Do not reboot a host at 100% root unless necessary.

**Step 2: Stop the VM and free safe space**
- **Purpose:** Stop qcow2 growth and restore Proxmox service operation.
- **Command(s):**
```bash
qm stop ${VMID}
apt clean
journalctl --vacuum-size=200M
rm -f /var/tmp/pve-reserved-ports.tmp.*
rm -rf /tmp/*
df -h /
```
- **Explanation:** These commands free safe cache/log/temp space.
- **Expected Output:**
```text
Filesystem ... Avail ... Mounted on
```
- **Verification:** `/` has at least several hundred MB free.
- **⚠️ Caveats/Traps:** Do not delete `/var/lib/vz/images/${VMID}`.

**Step 3: Move VM disks away from root-backed local storage**
- **Purpose:** Remove the underlying cause.
- **Command(s):**
```bash
qm config ${VMID} | grep -E 'scsi|virtio|sata|ide'
qm disk move ${VMID} scsi0 ${TARGET_STORAGE} --delete 1
qm disk move ${VMID} scsi1 ${TARGET_STORAGE} --delete 1
```
- **Explanation:** `${TARGET_STORAGE}` must be a backend with sufficient space.
- **Expected Output:**
```text
transferred ...
```
- **Verification:** `qm config ${VMID}` -> Disks no longer reference `local:`.
- **⚠️ Caveats/Traps:** If only 23 GB VFree remains, inspect existing LVs; do not create a new 500 GB LV blindly.

### 3. Configuration Files

Relevant Proxmox storage file:

```text
/etc/pve/storage.cfg
```

### 4. Troubleshooting & Recovery

- If `pvesm status` shows only `local`, inspect `lvs` for an unused or unconfigured thin pool.
- If `qm disk move` fails, use `qm move_disk` syntax depending on Proxmox version.
- If no storage is available, add physical storage or shrink/migrate disks after backup.

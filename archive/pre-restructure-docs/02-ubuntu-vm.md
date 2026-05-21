# VM Design

## Ubuntu VM Goals

The Ubuntu VM is designed for:

- local LLM inference
- embeddings
- hybrid RAG
- semantic graphs
- coding agents
- scientific paper summarization
- local-only workflows

---

# Ubuntu VM Creation

## VM Settings

```text
Machine: q35
BIOS: OVMF
CPU Type: host
SCSI Controller: VirtIO SCSI single
Network: VirtIO
QEMU Agent: enabled
```

## CPU Configuration

Initial configuration:

```text
8 vCPU
```

Critical correction:

The VM was initially configured as:

```text
cpu: x86-64-v2-AES
```

This prevented AVX/AVX2/FMA CPU features from being visible inside the VM.

This caused:

```text
Polars CPU compatibility warnings
```

Correct configuration:

```bash
qm set 2020 --cpu host
```

After reboot, AVX/AVX2/FMA flags became visible.

Verification:

```bash
grep -m1 '^flags' /proc/cpuinfo
```

Expected relevant flags:

```text
avx
avx2
fma
bmi1
bmi2
abm
movbe
pclmulqdq
```

---

# VM Storage Design

## Initial Mistake

The VM disks were created on:

```text
local
```

which maps to:

```text
/var/lib/vz
```

on the Proxmox host root filesystem.

VM disks:

```text
scsi0: local:2020/vm-2020-disk-1.qcow2,size=100G
scsi1: local:2020/vm-2020-disk-2.qcow2,size=500G
```

This caused:

- Ollama downloads inside the VM expanded the qcow2 images.
- Proxmox root filesystem reached 100%.
- Proxmox noVNC console failed.
- SSH instability.

Symptoms:

```text
Error 500: unable to write '/var/tmp/pve-reserved-ports.tmp.*'
```

Root cause:

```text
VM disks stored on root-backed local storage.
```

---

# Proxmox Host Recovery

## Root Filesystem Status

```text
/dev/mapper/lapan--vg-root 52G 52G 0 100% /
```

Emergency cleanup:

```bash
apt clean
journalctl --vacuum-size=200M
rm -f /var/tmp/pve-reserved-ports.tmp.*
rm -rf /tmp/*
```

---

# NVIDIA Drivers

Installed inside Ubuntu VM only.

No NVIDIA drivers installed on Proxmox host.

Example installation:

```bash
sudo ubuntu-drivers install --gpgpu
```

If `nvidia-smi` missing:

```bash
sudo apt install nvidia-utils-580-server
```

Verification:

```bash
nvidia-smi
```

---

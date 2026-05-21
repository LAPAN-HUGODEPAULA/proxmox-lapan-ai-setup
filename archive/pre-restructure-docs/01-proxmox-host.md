# Proxmox Host Configuration

## Proxmox Version

```text
Proxmox VE 9.1
Kernel: Linux 7.0.2-2-pve
```

## BIOS Configuration

Enabled:

- SVM
- IOMMU
- Above 4G Decoding
- Resizable BAR

---

# GRUB Configuration

Current working kernel parameters:

```text
quiet nomodeset iommu=pt modprobe.blacklist=nouveau
```

Important note:

```text
amd_iommu=on
```

was removed because the kernel reported:

```text
AMD-Vi: Unknown option - 'on'
```

IOMMU was validated with:

```bash
journalctl -k | grep -i iommu
```

Expected:

```text
iommu: Default domain type: Passthrough
```

---

# Proxmox Network Configuration

Stable working configuration:

```text
auto lo
iface lo inet loopback

iface enp6s0 inet manual

auto vmbr0
iface vmbr0 inet static
    address 192.168.100.46/24
    gateway 192.168.100.1
    bridge-ports enp6s0
    bridge-stp off
    bridge-fd 0
```

Notes:

- Proxmox host is intentionally headless.
- No NVIDIA drivers installed on host.
- Tailscale removed from host after networking instability.

---

#!/usr/bin/env bash
set -Eeuo pipefail

vmid="${VMID:-}"
stamp="$(date -u +%Y%m%d-%H%M%S)"
out="host-state-${stamp}.txt"

{
  echo "# Proxmox host state collection"
  echo "# Date: $(date -u --iso-8601=seconds)"
  echo
  echo "## Proxmox version"
  pveversion -v || true
  echo
  echo "## Kernel"
  uname -a || true
  echo
  echo "## Filesystems"
  df -h || true
  echo
  echo "## Proxmox storage"
  pvesm status || true
  echo
  echo "## LVM"
  pvs || true
  vgs || true
  lvs -a -o lv_name,vg_name,lv_size,lv_attr,origin,data_percent,metadata_percent,devices || true
  echo
  echo "## Block devices"
  lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINTS || true
  echo
  echo "## IOMMU / VFIO"
  journalctl -k --no-pager | grep -Ei 'iommu|amd-vi|vfio' || true
  echo
  echo "## NVIDIA PCI"
  lspci -nnk -d 10de: || true
  echo
  echo "## VM config"
  if [[ -n "${vmid}" ]]; then
    qm config "${vmid}" || true
  else
    echo "Set VMID=<id> to include qm config output."
  fi
} | tee "${out}"

echo "Wrote ${out}"

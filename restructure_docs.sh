#!/usr/bin/env bash
set -euo pipefail

# Reorganize the early flat documentation layout into the phase-based structure.
# Run from repository root. The script preserves the old docs in archive/pre-restructure-docs.

if [[ ! -f README.md ]]; then
  echo "Run this script from the repository root." >&2
  exit 1
fi

mkdir -p archive
if [[ -d docs && ! -d archive/pre-restructure-docs ]]; then
  cp -a docs archive/pre-restructure-docs
fi

mkdir -p \
  docs/00-project-context \
  docs/01-proxmox-host \
  docs/02-ubuntu-vm \
  docs/03-gpu-passthrough \
  docs/04-docker-and-services \
  docs/05-ai-research-platform \
  docs/06-operations \
  docs/07-troubleshooting \
  configs/proxmox \
  configs/ubuntu-vm \
  configs/ai-stack/jupyter \
  scripts

if [[ -f vm-config/etc/modprobe.d/vfio.conf ]]; then
  cp vm-config/etc/modprobe.d/vfio.conf configs/proxmox/vfio.conf
fi
if [[ -f vm-config/etc/modprobe.d/blacklist-nouveau.conf ]]; then
  cp vm-config/etc/modprobe.d/blacklist-nouveau.conf configs/proxmox/blacklist-nouveau.conf
fi
if [[ -f vm-config/etc/modules-load.d/vfio.conf ]]; then
  cp vm-config/etc/modules-load.d/vfio.conf configs/proxmox/modules-load-vfio.conf
fi
if [[ -f srv/ai/compose/core/docker-compose.yml ]]; then
  cp srv/ai/compose/core/docker-compose.yml configs/ai-stack/docker-compose.yml
fi
if [[ -f srv/ai/compose/core/jupyter/Dockerfile ]]; then
  cp srv/ai/compose/core/jupyter/Dockerfile configs/ai-stack/jupyter/Dockerfile
fi

echo "Structure created. Existing flat docs were preserved under archive/pre-restructure-docs."

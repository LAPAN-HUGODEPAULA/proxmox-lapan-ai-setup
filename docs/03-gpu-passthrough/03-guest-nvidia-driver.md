# Guest NVIDIA Driver

### 1. Objective & Prerequisites

- Install NVIDIA compute drivers inside Ubuntu VM only.
- Required previous state: `lspci` inside Ubuntu shows the NVIDIA GPU.
- Estimated time: 20-40 minutes. Risk level: medium.

### 2. Step-by-Step Execution

**Step 1: Confirm GPU visibility**
- **Purpose:** Avoid installing drivers before passthrough is working.
- **Command(s):**
```bash
lspci -nn | grep -Ei 'nvidia|10de|vga|3d|display|audio'
```
- **Explanation:** Driver installation is meaningful only if the PCI device is visible to the guest.
- **Expected Output:**
```text
... NVIDIA Corporation ... [10de:2d04]
```
- **Verification:** `lspci -nnk -d 10de:` -> Shows NVIDIA device details.
- **⚠️ Caveats/Traps:** If this returns nothing, fix passthrough first.

**Step 2: Install recommended GPGPU driver**
- **Purpose:** Install compute-oriented NVIDIA driver packages.
- **Command(s):**
```bash
sudo apt update
sudo apt install -y ubuntu-drivers-common
sudo ubuntu-drivers list --gpgpu
sudo ubuntu-drivers install --gpgpu
sudo reboot
```
- **Explanation:** `ubuntu-drivers` selects a supported driver branch for the running Ubuntu release.
- **Expected Output:**
```text
[MISSING] Installed NVIDIA driver package list.
```
- **Verification:** `dpkg -l | grep -E 'nvidia-driver|nvidia-utils'` -> Driver and utilities installed.
- **⚠️ Caveats/Traps:** `nvidia-smi` may be missing if the matching `nvidia-utils-*` package was not installed.

**Step 3: Install matching nvidia-utils if needed**
- **Purpose:** Provide `nvidia-smi` when the compute driver is installed without utilities.
- **Command(s):**
```bash
dpkg -l | grep -E 'nvidia-driver|nvidia-utils|libnvidia|nvidia-dkms' | sort
sudo apt install -y nvidia-utils-${NVIDIA_DRIVER_BRANCH}-server
sudo reboot
```
- **Explanation:** Match the utils branch to the installed driver branch, for example `580-server`.
- **Expected Output:**
```text
/usr/bin/nvidia-smi
```
- **Verification:** `nvidia-smi` -> Shows GPU, driver version, and CUDA version.
- **⚠️ Caveats/Traps:** Do not mix unrelated driver branches such as 580 and 595 unless intentionally migrating.

### 3. Configuration Files

No static config file is normally required.

### 4. Troubleshooting & Recovery

- `nvidia-smi: command not found`: install matching `nvidia-utils-*` package.
- `NVIDIA-SMI has failed`: check `lsmod | grep nvidia`, `dkms status`, and `mokutil --sb-state`.
- Secure Boot can block kernel modules; disable Secure Boot or enroll MOK if used.

# NVIDIA Container Runtime

### 1. Objective & Prerequisites

- Enable Docker containers to access the passed-through NVIDIA GPU.
- Required previous state: `nvidia-smi` works inside Ubuntu VM.
- Estimated time: 15 minutes. Risk level: medium.

### 2. Step-by-Step Execution

**Step 1: Install NVIDIA Container Toolkit**
- **Purpose:** Register NVIDIA runtime support with Docker.
- **Command(s):**
```bash
sudo apt-get update
sudo apt-get install -y --no-install-recommends ca-certificates curl gnupg2
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```
- **Explanation:** `nvidia-ctk runtime configure` writes Docker runtime configuration for GPU-enabled containers.
- **Expected Output:**
```text
INFO[0000] Config file does not exist; using empty config
INFO[0000] Wrote updated config to /etc/docker/daemon.json
```
- **Verification:** `sudo docker info | grep -i nvidia` -> Shows NVIDIA runtime support.
- **⚠️ Caveats/Traps:** Ensure existing Docker `data-root` in `/etc/docker/daemon.json` is preserved.

**Step 2: Test GPU from container**
- **Purpose:** Confirm Docker containers can use the GPU.
- **Command(s):**
```bash
sudo docker run --rm --gpus all nvidia/cuda:12.8.1-base-ubuntu24.04 nvidia-smi
```
- **Explanation:** This starts a temporary CUDA container and runs `nvidia-smi` inside it.
- **Expected Output:**
```text
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI ... Driver Version: ... CUDA Version: ...                                    |
+-----------------------------------------------------------------------------------------+
```
- **Verification:** The output names the RTX GPU.
- **⚠️ Caveats/Traps:** If host `nvidia-smi` works but container test fails, the issue is the container runtime, not passthrough.

### 3. Configuration Files

Docker daemon file:

```text
/etc/docker/daemon.json
```

Must retain:

```json
{
  "data-root": "/srv/ai/docker"
}
```

### 4. Troubleshooting & Recovery

- `could not select device driver "" with capabilities: [[gpu]]`: NVIDIA runtime not configured or Docker not restarted.
- Docker daemon fails after editing JSON: validate syntax with `python3 -m json.tool /etc/docker/daemon.json`.
- Container CUDA version can be newer than driver-supported CUDA only within compatibility limits; test with a known-good CUDA base image.

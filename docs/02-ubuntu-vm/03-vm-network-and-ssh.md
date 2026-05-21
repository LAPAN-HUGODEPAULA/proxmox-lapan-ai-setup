# VM Network and SSH

### 1. Objective & Prerequisites

- Configure reliable SSH administration and a static VM address.
- Required previous state: Ubuntu installed and reachable by Proxmox console.
- Estimated time: 20 minutes. Risk level: medium.

### 2. Step-by-Step Execution

**Step 1: Configure static network**
- **Purpose:** Make the AI VM reachable at a predictable LAN address.
- **Command(s):**
```bash
ip -br link
sudo vim /etc/netplan/01-ai-vm.yaml
sudo netplan apply
```
- **Explanation:** Use `configs/ubuntu-vm/netplan.example.yaml`; replace `${VM_NIC_NAME}`, `${VM_IP}`, and DNS values.
- **Expected Output:**
```text
No error output from netplan apply.
```
- **Verification:** `ip -br addr` -> VM NIC shows `${VM_IP}/${CIDR_PREFIX}`.
- **⚠️ Caveats/Traps:** Keep console access open while applying Netplan changes.

**Step 2: Install SSH public key**
- **Purpose:** Enable secure key-based administration.
- **Command(s):**
```bash
ssh-copy-id -i ~/.ssh/${PUBLIC_KEY_FILE}.pub ${VM_USER}@${VM_IP}
ssh -i ~/.ssh/${PRIVATE_KEY_FILE} ${VM_USER}@${VM_IP}
```
- **Explanation:** The comment at the end of the `.pub` key is only a label and need not match `${VM_USER}`.
- **Expected Output:**
```text
${VM_USER}@${VM_HOSTNAME}:~$
```
- **Verification:** Open a second SSH session before disabling password login.
- **⚠️ Caveats/Traps:** Never paste private keys into `authorized_keys`; only paste `.pub` content.

**Step 3: Harden SSH**
- **Purpose:** Disable root and password login after key login is proven.
- **Command(s):**
```bash
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sudo vim /etc/ssh/sshd_config
sudo systemctl restart ssh
```
- **Explanation:** Apply the settings from `configs/ubuntu-vm/sshd_config.hardening.example`.
- **Expected Output:**
```text
No output from systemctl restart ssh.
```
- **Verification:** `ssh -i ~/.ssh/${PRIVATE_KEY_FILE} ${VM_USER}@${VM_IP}` -> New key-based login works.
- **⚠️ Caveats/Traps:** Do not close the current SSH session until a second login succeeds.

**Step 4: Enable UFW for SSH only**
- **Purpose:** Restrict inbound traffic to LAN SSH before service tunnels are used.
- **Command(s):**
```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow from ${LAN_CIDR} to any port 22 proto tcp
sudo ufw enable
sudo ufw status verbose
```
- **Explanation:** This allows SSH from the LAN subnet and denies other inbound traffic.
- **Expected Output:**
```text
22/tcp ALLOW IN ${LAN_CIDR}
```
- **Verification:** Open a second SSH connection from a LAN workstation.
- **⚠️ Caveats/Traps:** Docker-published ports need explicit localhost binding; do not rely only on UFW.

### 3. Configuration Files

- `configs/ubuntu-vm/netplan.example.yaml`
- `configs/ubuntu-vm/sshd_config.hardening.example`

### 4. Troubleshooting & Recovery

- If SSH fails, use Proxmox console and revert `/etc/ssh/sshd_config.bak`.
- If UFW locks you out, use console and run `sudo ufw disable`.
- If DNS fails, check the Netplan nameserver section.

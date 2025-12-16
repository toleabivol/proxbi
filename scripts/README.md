# Scripts

## Start-ProxmoxServer helper

`Start-ProxmoxServer.ps1` is a PowerShell 7 script that pings your Proxmox server, sends a Wake-on-LAN packet if it is offline, waits until it responds, and then prompts before exiting.

### Requirements
- PowerShell 7 (`pwsh.exe`) available in your PATH. Install it from [aka.ms/pscore6](https://aka.ms/pscore6) if it is missing.
- Wake-on-LAN must be enabled for the target server's network interface.
- UDP broadcast traffic must be allowed between the thin client and the server.

### Files
- `Start-ProxmoxServer.ps1` – main script. Customize the default parameter values at the top to match your environment.
- `Start-ProxmoxServer.cmd` – convenience launcher that calls PowerShell with `-ExecutionPolicy Bypass`. This avoids the "digitally unsigned" error on systems that block unsigned scripts by default.

Keep both files in the same folder on the thin client.

### First run (remove the "digitally signed" warning)
1. **Unblock the files** (one of the following):
   - Right-click each file → **Properties** → check **Unblock** → **Apply**.
   - Or run `Unblock-File -Path .\Start-ProxmoxServer.ps1, .\Start-ProxmoxServer.cmd` from a PowerShell prompt in the download folder.
2. (Optional) Adjust the default parameters at the top of `Start-ProxmoxServer.ps1`.
3. Launch `Start-ProxmoxServer.cmd`. This starts PowerShell 7 with execution policy bypassed so the script can run even if it is not digitally signed.

### Running with custom parameters
If you prefer to override the parameters at launch, call the `.cmd` file with additional arguments. For example:

```cmd
Start-ProxmoxServer.cmd -ServerAddress 192.168.1.50 -ServerMacAddress AA-BB-CC-DD-EE-FF -TimeoutSeconds 300
```

All parameters supported by the PowerShell script are available. See the comment-based help inside `Start-ProxmoxServer.ps1` for details.

### Troubleshooting
- **"PowerShell 7 not found"** – Install PowerShell 7 from [aka.ms/pscore6](https://aka.ms/pscore6) and ensure `pwsh.exe` is in the PATH.
- **Server never responds** – Verify the MAC address, broadcast address, firewall rules, and that Wake-on-LAN is enabled in the BIOS and OS.

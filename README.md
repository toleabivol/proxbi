
# ProxBi
(WIP) 

Build a server with multiple GPU-powered virtual machines — perfect for families, classrooms, and homelab enthusiasts.

---

## Table of Contents
1. [Overview](#overview)
2. [Features](#features)
3. [Hardware Requirements](#hardware-requirements)
4. [Quick Start](#quick-start)
5. [Setup Instructions](#setup-instructions)
6. [Templates & Scripts](#templates--scripts)
7. [Demo & YouTube Videos](#demo--youtube-videos)
8. [Support & Sponsorship](#support--sponsorship)
9. [License](#license)

---

## Overview
**ProxBi** helps you convert one powerful server into multiple independent desktops for gaming, learning, or productivity. Each user gets their own GPU-powered VM accessible via thin clients or remote desktop.


### One Server vs Separate Server per User

| Feature / Factor              | One Server + Thin Clients                                                             | Separate Server per User                                  |
|-------------------------------|---------------------------------------------------------------------------------------|-----------------------------------------------------------|
| **Hardware Cost**             | Lower — shared components (MB, CPU, PSU, case) reduce overall cost                    | Higher — each user needs a full system                    |
| **GPU Allocation**            | Multiple GPUs passed through to different VMs                                         | Each user requires their own GPU                          |
| **Noise**                     | Minimal in user rooms — server can be placed in a locker, basement, or dedicated room | High — each system produces its own noise                 |
| **Power Consumption**         | Lower — single system with shared components                                          | Higher — many separate systems                            |
| **Maintenance**               | Centralized updates and monitoring                                                    | More effort — updates and troubleshooting for each system |
| **Space Requirements**        | Compact — one server, small thin clients                                              | Large — full-sized PCs for each user                      |
| **Flexibility / Scalability** | High — can add VMs or GPUs as needed                                                  | Limited — adding new users means buying more hardware     |
| **Initial Setup Complexity**  | Higher — requires knowledge of Proxmox and GPU passthrough                            | Lower — plug-and-play desktop PCs                         |
| **User Experience**           | Thin client latency may be slightly higher, but manageable                            | Native experience, zero virtualization overhead           |

> **Tip:** Placing the server in a basement or closet reduces noise in living areas while keeping thin clients quiet and efficient. Shared components like motherboard, PSU, and case save money compared to building full PCs for each user.


---

## Features
- Automated scripts for Proxmox and GPU passthrough
- Ready-to-use VM templates for Windows 11
- Optimized performance for gaming, coding, and creative apps  
- Multi-user management for family, classroom, or homelab setups  
- Troubleshooting tips and configuration guides included
- Demo & Videos

---

## Hardware Requirements
> **Tip:** Think about future expansions
- Case with enough space for all components
  - Fans and airflow to keep it cool
  - noise/quietness grade depending on where the server will be placed 
- PSU with enough power 
- Motherboard with enough and correct ports/pins
- CPU with IOMMU support and enough cores for each user/VM.
- 1+ GPUs for passthrough. One for each user/VM.
- Sufficient RAM (recommend ≥14GB per user/VM).
- [Proxmox VE 9.x compatible server](https://www.proxmox.com/en/products/proxmox-virtual-environment/requirements)
- Thin clients or remote desktop clients for users (mini-PC, laptop, PC, mac etc.)
- Enough storage. Preferable SSD or M2.

---

## Quick Start

(WIP)

## Setup Instructions

### Wake-on-LAN (WoL)
Wake-on-LAN (WoL) is a networking standard that allows a computer to be turned on or woken from a low-power state by a special network message called a "magic packet". 
To use it, the target computer's motherboard and network adapter must support WoL, and the computer must remain connected to a power source, even when shut down. 
The feature must also be enabled in the computer's BIOS/UEFI and the network adapter's settings.

1. Enable WoL
   1. from BIOS. Depending on your Motherboard enter BIOS and:
      - enable the option like `Power On By PCI-E / PCI`
      - and disable `ErP Ready` (this one cuts power to NIC when server stopped)
   2. in proxmox linux (if not already):
      - `ethtool <your-nic>` You should see `Supports Wake-on: pumbg` `Wake-on: g` if not :
        - edit `nano /etc/network/interfaces` and add these 2 lines under your interface `<your nic>`:
          - `post-up /usr/sbin/ethtool -s eno1 wol g`
          - `post-down /usr/sbin/ethtool -s eno1 wol g`

2. Use a WoL client
   - Windows
     - GUI
       - From MS Store search for any WoL or MagicPacket client e.g. https://apps.microsoft.com/detail/9wzdncrcw1mx (tested by me on Windows 10/11)
       - https://github.com/basildane/WakeOnLAN/releases/tag/2.12.4 (tested by me on Win 10)
     - PowerShell
       - https://gist.github.com/alimbada/4949168
       - You can make a shortcut in windows 
   - Linux
     - GUI
       - https://github.com/muflone/gwakeonlan/ (also from App Center) (tested by me on Ubuntu 24)
       - Ampare Wake on LAN (from App Center) (did not open on my Ubuntu also size too big ~109MB)
     - Terminal
       - wakeonlan (tested by me on Ubuntu 24)
         - `sudo apt install wakeonlan`
         - `wakeonlan <mac address of the server>`
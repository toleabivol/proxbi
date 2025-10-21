
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

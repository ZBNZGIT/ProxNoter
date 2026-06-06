# ProxNoter 🏷️

[![Proxmox VE](https://img.shields.io/badge/Proxmox-VE-E74C3C?style=flat-square&logo=proxmox&logoColor=white)](https://www.proxmox.com)
[![Bash](https://img.shields.io/badge/Language-Bash-4EAA25?style=flat-square&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)

**ProxNoter** is a lightweight, interactive CLI utility for Proxmox VE that transforms boring text fields into beautiful, automated dashboard-style notes for your Virtual Machines (VMs) and Linux Containers (LXCs). 

By leveraging dynamic markdown and Shields.io badges, it injects structured system metadata—including auto-detected IP addresses, mapped ports, and service icons—directly into your PVE configuration notes.

---

## ✨ Features

* **🚀 One-Command Install:** Installs globally on your PVE node and adds a convenient bash alias.
* **🔍 Auto-Network Detection:** Automatically fetches IPv4 addresses natively from running LXCs (`pct`) and VMs (`qm guest`).
* **🎨 Input Validation:** Strict regex loops protect your URLs by validating custom Hex colors or CSS color names while stripping accidental spaces or `#` symbols.
* **📦 selfh.st/icons Integration:** Easily pair your apps with high-quality tech icons.
* **🛡️ Shields.io Badges:** Automatically url-encodes parameters (like slashes in `80/TCP`) to render perfect, high-visibility layout badges.

---

## 📸 Preview

When you select a VM or LXC in your Proxmox web UI, your notes panel goes from plain text to a clean, centralized asset card:

<img width="657" height="363" alt="image" src="https://github.com/user-attachments/assets/c2b277af-65a7-46c3-a689-8ad3034d9304" />

## 🚀 One-Command Quick Install

Run the following command as **root** (or via `sudo`) inside your Proxmox VE terminal. This script automatically downloads the binary tool, places it in your local environment paths, sets execution permissions, and configures a global bash alias:

```bash
bash -c "$(curl -sSL https://raw.githubusercontent.com/ZBNZGIT/ProxNoter/main/install-proxnoter.sh)"

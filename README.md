# Discord Linux DEB Auto Updater

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

One-shot systemd service that automatically checks for the latest Discord `.deb` version on Linux and updates it at system startup **if needed**.  
Runs once at boot, compares the latest version with the installed version, installs the update if necessary, and then disables itself.

---

## Features

- ✅ Checks the latest Discord `.deb` via Discord's official API
- ✅ Compares with installed version
- ✅ Installs only if a newer version is available
- ✅ Runs **once at system startup**
- ✅ Automatically disables itself after execution
- ✅ Runs as `root` using systemd for proper permissions

---

## Installation

Run the installer script as root:

```bash
chmod +x install.sh
sudo ./install.sh

# Setting up VPS from scratch using Xray + VLESS + XTLS + Reality + NGINX + VPS protection

Detailed information is located in each bash script separately.

---

## Installation

### Server update
```bash
sudo apt update && sudo apt upgrade
```

### Downloading files
Download and unzip the archive without installing additional utilities.
```bash
wget https://github.com/ink-pwd/XRay-config/archive/refs/heads/main.zip -O xray.zip && python3 -m zipfile -e xray.zip . && rm xray.zip
```

### Run default setup
```bash
cd XRay-config-main && chmod +x setup.sh && ./setup.sh
```

### Other func
Use add-user.sh <name> and delete-user.sh <name> to add and remove users respectively

## Recommendations
Close the IPv6 address if you have.
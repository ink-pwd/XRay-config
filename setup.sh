#!/bin/bash

set -e

echo "=== Xray CFG SETUP START ==="

echo "[1/6] Making scripts executable..."
chmod +x *.sh

echo "[2/6] Installing dependencies..."
./install-deps.sh

echo "[3/6] Applying server security hardening..."
./secure-server.sh

echo "[4/6] Installing Xray..."
./install-xray.sh

echo "[5/6] Configuring Xray Reality..."
./config-reality.sh

echo "[6/6] Setting up nginx fake site..."
./nginx-fake.sh 

echo ""
echo "=== SETUP COMPLETE ==="
echo "Xray + Reality CFG + Nginx + Security are ready"
echo "use ./app-user.sh name for add new user"
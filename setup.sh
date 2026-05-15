#!/bin/bash

set -e

echo "=== Xray CFG SETUP START ==="

echo "[1/7] Making scripts executable..."
chmod +x *.sh

echo "[2/7] Create Xray environment..."
./create-env.sh

echo "[3/7] Installing dependencies..."
./install-deps.sh

echo "[4/7] Applying server security hardening..."
./secure-server.sh

echo "[5/7] Installing Xray..."
./install-xray.sh

echo "[6/7] Configuring Xray Reality..."
./config-reality.sh

echo "[7/7] Setting up nginx fake site..."
./nginx-fake.sh 

echo ""
echo "=== SETUP COMPLETE ==="
echo "Xray + Reality CFG + Nginx + Security are ready"
echo "use ./app-user.sh <name> for add new user"
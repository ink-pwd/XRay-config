#!/bin/bash

# Получаем свой айпи
IP=$(curl -s ifconfig.me)

# Защита от пустого IP
if [ -z "$IP" ]; then
    echo "Error: cannot get public IP"
    exit 1
fi

cat > /root/xray.env <<EOF
SERVER_IP=$IP
SHORT_ID=a1b2c3d4e5f6
CONFIG=/usr/local/etc/xray/config.json
PORT=1443
PUBLIC_KEY=
EOF

# Защита
chmod 600 /root/xray.env

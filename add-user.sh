#!/bin/bash

# Расположение конфига xray
CONFIG="/usr/local/etc/xray/config.json"


# Генерируем уникальный UUID(приватный айди пользователя)
UUID=$(cat /proc/sys/kernel/random/uuid)
# Получаем имя пользователя из аргумента скрипта
NAME="$1"

PUBLIC_KEY=$(cat /root/xray-public.key)
SERVER_IP="ТВОЙ_IP"
SHORT_ID="a1b2c3d4e5f6"

# Создаем временный файл что бы безопасно хранить инфу
TMP=$(mktemp)

jq --arg uuid "$UUID" --arg name "$NAME" '
.inbounds[0].settings.clients += [
  {
    id: $uuid,
    flow: "xtls-rprx-vision",
    email: $name
  }
]
' "$CONFIG" > "$TMP" && mv "$TMP" "$CONFIG"

# Перезапускаемся после добавления пользователя
systemctl restart xray

# Формируем ссылку для подключения клиента
LINK="vless://${UUID}@${SERVER_IP}:443?security=reality&sni=www.pinterest.com&fp=chrome&pbk=${PUBLIC_KEY}&sid=${SHORT_ID}&type=tcp&flow=xtls-rprx-vision#${EMAIL}"

echo ""
echo "UUID: $UUID"
echo ""
echo "VLESS:"
echo "$LINK"
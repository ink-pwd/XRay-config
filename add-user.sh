#!/bin/bash

# Проверка аргумента
if [ -z "$1" ]; then
    echo "Использование: $0 <username>"
    exit 1
fi

# Расположение конфига xray
CONFIG="/usr/local/etc/xray/config.json"


# Генерируем уникальный UUID(приватный айди пользователя)
UUID=$(cat /proc/sys/kernel/random/uuid)
# Получаем имя пользователя из аргумента скрипта
NAME="$1"

PUBLIC_KEY=$(cat /root/xray-public.key)
SERVER_IP="ТВОЙ_IP"
SHORT_ID="a1b2c3d4e5f6"



# Защита от забытого IP
if [ "$SERVER_IP" = "ТВОЙ_IP" ]; then
    echo "Error: please indicate SERVER_IP"
    exit 1
fi

# Создаем временный файл что бы безопасно хранить инфу
TMP=$(mktemp)

# Добавляем пользователя
jq --arg uuid "$UUID" --arg name "$NAME" '
.inbounds[0].settings.clients += [
  {
    id: $uuid,
    flow: "xtls-rprx-vision",
    email: $name
  }
]
' "$CONFIG" > "$TMP"

# Проверка jq
if [ $? -ne 0 ]; then
    echo "Error: jq failed"
    rm -f "$TMP"
    exit 1
fi

# Замена конфига с сохранением прав
install -o root -g root -m 644 "$TMP" "$CONFIG"
rm -f "$TMP"

# Перезапускаемся после добавления пользователя
systemctl restart xray

# Формируем ссылку для подключения клиента
# encryption=none - уточняем, что VLESS ничего не шифрует
LINK="vless://${UUID}@${SERVER_IP}:443?encryption=none&security=reality&sni=www.pinterest.com&fp=chrome&pbk=${PUBLIC_KEY}&sid=${SHORT_ID}&type=tcp&flow=xtls-rprx-vision#${NAME}"

echo ""
echo "UUID: $UUID"
echo ""
echo "VLESS:"
echo "$LINK"
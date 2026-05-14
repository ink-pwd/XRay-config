#!/bin/bash

# Проверяем был ли передан ник
if [ -z "$1" ]; then
    echo "Usage: $0 <username>"
    exit 1
fi

USERNAME="$1"
CONFIG="/usr/local/etc/xray/config.json"
TMP=$(mktemp)

# Проверка существования пользователя
if ! grep -q "\"email\": \"$USERNAME\"" "$CONFIG"; then
    echo "User '$USERNAME' not found"
    rm -f "$TMP"
    exit 1
fi

# Обработка JSON
jq --arg name "$USERNAME" '
.inbounds[0].settings.clients |= map(select(.email != $name))
' "$CONFIG" > "$TMP"

# Проверка jq
if [ $? -ne 0 ]; then
    echo "Error processing config"
    rm -f "$TMP"
    exit 1
fi

# Замена конфига с сохранением прав
install -o root -g root -m 644 "$TMP" "$CONFIG"

rm -f "$TMP"

systemctl restart xray

echo "User '$USERNAME' was deleted"
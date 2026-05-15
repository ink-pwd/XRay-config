#!/bin/bash

# Подгружаем общие функции
source ./common.sh


# Проверка аргумента
if [ -z "$1" ]; then
    echo "Использование: $0 <username>"
    exit 1
fi



# Генерируем уникальный UUID(приватный айди пользователя)
UUID=$(cat /proc/sys/kernel/random/uuid)
# Получаем имя пользователя из аргумента скрипта
NAME="$1"


CONFIG=$(get_env CONFIG)
PUBLIC_KEY=$(get_env PUBLIC_KEY)
SERVER_IP=$(get_env SERVER_IP)
SHORT_ID=$(get_env SHORT_ID)


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
#!/bin/bash

# Подгружаем общие функции
source ./common.sh

# Расположение пустого конфига xray
CONFIG=$(get_env CONFIG)

# Reality ключи шифрования(server + client)
OUT=$(xray x25519)

PRIVATE=$(echo "$OUT" | grep "PrivateKey" | awk -F': ' '{print $2}')
PUBLIC=$(echo "$OUT" | grep "PublicKey" | awk -F': ' '{print $2}')

# Сохраняем ключ клиента для добавления новых пользователей
sed -i "s|^PUBLIC_KEY=.*|PUBLIC_KEY=$PUBLIC|" /root/xray.env

# Стандартный порт для https
PORT=$(get_env PORT)

# конфиг VLESS + REALITY
# логирование полностью отключено, не храним ничего на сервере
# AsIs - прокидывает домен от клиента дальше, что бы dns запрос был от самой ОС сервера
# rules блокирует запрос клиента, если тот пытается обратиться к локальным серверам
# слушаем все сетевые интерфейсы 0.0.0.0 для возможности подключения пользователя
# протокол VLESS - тип скоростного подключения, за шифрование отвечает Reality
# Пользователей добавляем в отдельном скрипте
# decryption: none - уточняем что VLESS не шифрует данные
# fallbacks - если соединение пришло на 443 порт и прошло TSL уровень, но это не VLESS, тогда перебрасываем его на 80 порт
# включаем reality для маскировки трафика под обычные https
# show: false - не показывать служебную информацюи и дебаг
# маскируем трафик под обращения на pinterest по tcp порту, клиент их видит без порта
# xver - версия встроенного протокола Reality
# privateKey - приватный ключ шифрования
# shortIds - дополнительная безопасность сервера, проверяет совпадение его с shortIds клиента
# sniffing - включаем анализ трафика
# outbounds - это указано что идет клиенту, блокировка локального трафика и отправка ответов на обычные запросы
# levels 0 - настройка обычного подключенного клиента(можно класифицировать и делать лимиты используя 1, 2)
# handshake - разрыв соединения, если нет рукопожатия с клиентом в течении 3-х секунд(защита от зависших подключений)
# connIdle - разрыв соединения с ресурсом на сервере, если нет трафика 2 минуты
cat > "$CONFIG" <<EOF
{
    "log": {
        "loglevel": "none"
    },
    "routing": {
        "domainStrategy": "AsIs",
        "rules": [
            {
                "type": "field",
                "ip": [
                    "geoip:private"
                ],
                "outboundTag": "block"
            }
        ]
    },
    "inbounds": [
        {
            "listen": "0.0.0.0",
            "port": $PORT,
            "protocol": "vless",
            "settings": {
                "clients": [],
                "fallbacks": [
                    {
                        "dest": 80
                    }
                ],
                "decryption": "none"
            },

            "streamSettings": {
                "network": "tcp",
                "security": "reality",
                "realitySettings": {
                    "show": false, 
                    "dest": "www.pinterest.com:443",
                    "xver": 0,
                    "serverNames": [ 
                        "www.pinterest.com"
                    ],
                    "fingerprint": "chrome",
                    "privateKey": "$PRIVATE", 
                    "shortIds": [ 
                        "a1b2c3d4e5f6"
                    ]
                }
            },
            "sniffing": {
                "enabled": true,
                "destOverride": [
                    "http",
                    "tls",
                    "quic"
                ]
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom",
            "tag": "direct"
        },
        {
            "protocol": "blackhole",
            "tag": "block"
        }
    ],
    "policy": {
        "levels": {
            "0": {
                "handshake": 5,
                "connIdle": 120
            }
        }
    }
}
EOF

echo "PUBLIC KEY: $PUBLIC"
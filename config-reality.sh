#!/bin/bash

# Расположение пустого конфига xray
CONFIG="/usr/local/etc/xray/config.json"

# Генерируем уникальный UUID(приватный айди пользователя)
UUID=$(cat /proc/sys/kernel/random/uuid)

# Reality ключи шифрования(server + client)
read -r PRIV PUB <<< $(xray x25519)

# Стандартный порт для https
PORT=443

# конфиг VLESS + REALITY
# логирование полностью отключено, не храним ничего на сервере
# AsIs - прокидывает домен от клиента дальше, что бы dns запрос был от самой ОС сервера
# rules блокирует запрос клиента, если тот пытается обратиться к локальным серверам
# слушаем все сетевые интерфейсы 0.0.0.0 для возможности подключения пользователя
# протокол VLESS - тип скоростного подключения, за шифрование отвечает Reality
# UUID для первого пользователя генерируем выше
# xtls-rprx-vision - режим передачи данных в VLESS, оптимизирующий скорость и работу с TLS/Reality
# decryption: none - уточняем что VLESS не шифрует данные
# fallbacks - если к нам пытается подключится не vpn клиент, а сканер либо еще кто-то - перенаправляем его на сайт нашего vps
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
                "clients": [
                    {
                        "id": "$UUID",
                        "flow": "xtls-rprx-vision"
                    }
                ],
                "decryption": "none"
            },
            "fallbacks": [
                {
                    "dest": 80
                }
            ],

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
                    "privateKey": "$PRIV", 
                    "shortIds": [ 
                        "a1b2c3d4e5f6" // any string from 0 to F up to 16 digits
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
                "handshake": 3,
                "connIdle": 120
            }
        }
    }
}
EOF

echo "UUID: $UUID"
echo "PUBLIC KEY: $PUB"
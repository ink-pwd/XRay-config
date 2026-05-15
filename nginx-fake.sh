#!/bin/bash

# Подгружаем общие функции
source ./common.sh

PORT=$(get_env PORT | tr -d '[:space:]')

if [[ -z "$PORT" || ! "$PORT" =~ ^[0-9]+$ ]]; then
    echo "ERROR: invalid PORT: [$PORT]"
    exit 1
fi

# Генерация самоподписанного SSL-сертификата
mkdir -p /etc/nginx/ssl
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/selfsigned.key \
    -out /etc/nginx/ssl/selfsigned.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

# Конфигурация Nginx

cat > /etc/nginx/nginx.conf <<'EOF'
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
    worker_connections 1024;
    multi_accept on;
}

stream {
    map $ssl_preread_server_name $backend {
        www.pinterest.com    127.0.0.1:REALITY_PORT_PLACEHOLDER;
        default              127.0.0.1:8443;
    }

    server {
        listen 443;
        ssl_preread on;
        proxy_pass $backend;
        proxy_connect_timeout 3s;
        proxy_timeout 10s;
    }
}
EOF

# Подставляем порт
sed -i "s|REALITY_PORT_PLACEHOLDER|${PORT}|" /etc/nginx/nginx.conf

# Дописываем http-блок
cat >> /etc/nginx/nginx.conf <<'EOF'

http {
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    gzip on;
    gzip_disable "msie6";

    server {
        listen 80 default_server;
        server_name _;

        root /var/www/html;
        index index.html;

        location / {
            try_files $uri $uri/ =404;
        }
    }

    server {
        listen 8443 ssl;
        server_name _;

        ssl_certificate /etc/nginx/ssl/selfsigned.crt;
        ssl_certificate_key /etc/nginx/ssl/selfsigned.key;
        
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;

        root /var/www/html;
        index index.html;

        location / {
            try_files $uri $uri/ =404;
        }
    }
}
EOF

# Создание страницы-заглушки
mkdir -p /var/www/html
cat > /var/www/html/index.html <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Site</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background: #f5f5f5;
        }
        .box {
            text-align: center;
            padding: 40px;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        a { color: #333; text-decoration: none; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <div class="box">
        <h1>Hello!</h1>
        <p><a href="https://google.com">Continue</a></p>
    </div>
</body>
</html>
EOF

# Запуск Nginx
systemctl enable nginx
systemctl restart nginx


# Теперь xray доступен только локально, если подключение идет с правильным SNI
#!/bin/bash

# Обновляем список доступных пакетов
apt update && apt upgrade

# Ставим nginx что бы создать сайт
apt install nginx -y
apt install openssl -y
apt-get install libnginx-mod-stream -y

# Для удобного редактирования json
apt install jq -y

# Firewall
apt install ufw -y

# fail2ban (защита ssh)
apt install fail2ban -y
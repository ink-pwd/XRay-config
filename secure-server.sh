#!/bin/bash

# Закрываем лишние порты firewall(оставляем ssh, nginx(site), vpn)
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp

ufw --force enable


# Баним на час ip, если более 5-х раз был неправильно введен пароль ssh
systemctl enable fail2ban
systemctl start fail2ban

cat > /etc/fail2ban/jail.local <<EOF
[sshd]
enabled = true
port = 22
maxretry = 5
findtime = 10m
bantime = 1h
EOF
systemctl restart fail2ban
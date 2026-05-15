#!/bin/bash

# Закрываем лишние порты firewall(оставляем ssh, nginx(80/443)

# Закрываем все, что не разрешено
ufw default deny incoming
ufw default allow outgoing

# Разрешаем нужное
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp

ufw --force enable


# Баним на час ip, если более 5-х раз был неправильно введен пароль ssh

cat > /etc/fail2ban/jail.local <<EOF
[sshd]
enabled = true
port = 22
maxretry = 5
findtime = 10m
bantime = 1h
EOF


systemctl enable fail2ban
systemctl start fail2ban
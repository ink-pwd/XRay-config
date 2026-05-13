#!/bin/bash

# Обновляем список доступных пакетов
apt update

# Ставим nginx что бы создать сайт
apt install nginx -y

# Для удобного редактирования json
apt install jq -y
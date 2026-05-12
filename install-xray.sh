#!/bin/bash

# Обновляем список доступных пакетов
sudo apt update

# Качаем и устанавливаем голый движок xray с github
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

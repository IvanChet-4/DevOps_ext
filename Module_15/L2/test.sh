#!/bin/bash

# Останавливать скрипт при любой ошибке
set -e

# 1. Добавление официального GPG-ключа Docker:
sudo apt update
sudo apt install -y ca-certificates curl git
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# 2. Добавление репозитория в Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

# 3. Обновление индексов и установка Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 4. Настройка репозитория проекта
REPO_URL="https://github.com/IvanChet-4/shvirtd-example-python.git"
TARGET_DIR="/opt/shvirtd-example-python"

if [ -d "$TARGET_DIR" ]; then
    echo "Репозиторий уже существует. Обновляем..."
    cd "$TARGET_DIR"
    # Выполняем pull от имени root/sudo, так как директория в /opt
    sudo git pull origin main  
else
    echo "Клонируем репозиторий..."
    # Клонируем сразу с использованием sudo в целевую директорию
    sudo git clone "$REPO_URL" "$TARGET_DIR"
    cd "$TARGET_DIR"
fi

# 5. Запуск проекта с помощью docker compose
# Используем sudo, так как группа docker еще не применилась к текущему пользователю
echo "Запуск контейнеров..."
sudo docker compose up -d

#!/bin/bash

# Проверка прав root
if [[ $EUID -ne 0 ]]; then
    echo "Ошибка: Скрипт должен запускаться с правами root" >&2
    exit 1
fi

# Функция для проверки IP-адреса
validate_ip() {
    local ip=$1
    [[ $ip =~ ^(0|[1-9][0-9]?|1[0-9]{2}|2[0-4][0-9]|25[0-5])$ ]] || return 1
    return 0
}

# Функция для проверки интерфейса
validate_interface() {
    local interface=$1
    if ! ip link show "$interface" &>/dev/null; then
        return 1
    fi
    return 0
}

# Функция для сканирования одного IP
scan_ip() {
    local ip=$1
    echo "[*] IP: $ip"
    arping -c 3 -i "$INTERFACE" "$ip" 2>/dev/null
}

# Основная функция сканирования
perform_scan() {
    local start_subnet=$1
    local end_subnet=$2
    local start_host=$3
    local end_host=$4
    
    for SUBNET in $(seq $start_subnet $end_subnet); do
        for HOST in $(seq $start_host $end_host); do
            scan_ip "${PREFIX}.${SUBNET}.${HOST}"
        done
    done
}

# Проверка количества аргументов
if [[ $# -lt 2 ]]; then
    echo "Использование: $0 <PREFIX> <INTERFACE> [SUBNET] [HOST]" >&2
    echo "Примеры:" >&2
    echo "  $0 $PREFIX $INTERFACE          # Сканирование всей сети " >&2
    echo "  $0 $PREFIX $INTERFACE $SUBNET        # Сканирование подсети " >&2
    echo "  $0 $PREFIX $INTERFACE $SUBNET $HOST    # Сканирование одного IP " >&2
    exit 1
fi

PREFIX="$1"
INTERFACE="$2"
SUBNET="${3:-}"
HOST="${4:-}"

# Проверка формата PREFIX (должен быть в формате xxx.xxx)
if [[ ! $PREFIX =~ ^[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    echo "Ошибка: PREFIX должен быть в формате xxx.xxx" >&2
    exit 1
fi

# Октеты PREFIX
IFS='.' read -r octet1 octet2 <<< "$PREFIX"

# Первый октет PREFIX не может быть 0
if [[ $octet1 -eq 0 ]]; then
    echo "Ошибка: Первый октет PREFIX не может быть 0" >&2
    exit 1
fi

# Проверка первого октета PREFIX
IFS='.' read -r octet1 octet2 <<< "$PREFIX"
if ! validate_ip "$octet1" || ! validate_ip "$octet2"; then
    echo "Ошибка: Неверный формат PREFIX" >&2
    exit 1
fi

# Проверка интерфейса
if ! validate_interface "$INTERFACE"; then
    echo "Ошибка: Интерфейс $INTERFACE не существует" >&2
    exit 1
fi

# Определение диапазонов сканирования
if [[ -z "$SUBNET" && -z "$HOST" ]]; then
    # Сканирование всей сети
    echo "[*] Сканирование всей сети ${PREFIX}.0.0/16"
    perform_scan 0 255 1 255
    
elif [[ -n "$SUBNET" && -z "$HOST" ]]; then
    # Проверка SUBNET
    if ! validate_ip "$SUBNET"; then
        echo "Ошибка: SUBNET должен быть числом от 0 до 255" >&2
        exit 1
    fi
    # Сканирование одной подсети
    echo "[*] Сканирование подсети ${PREFIX}.${SUBNET}.0/24"
    perform_scan "$SUBNET" "$SUBNET" 1 255
    
elif [[ -n "$SUBNET" && -n "$HOST" ]]; then
    # Проверка SUBNET и HOST
    if ! validate_ip "$SUBNET"; then
        echo "Ошибка: SUBNET должен быть числом от 0 до 255" >&2
        exit 1
    fi
    if ! validate_ip "$HOST"; then
        echo "Ошибка: HOST должен быть числом от 0 до 255" >&2
        exit 1
    fi
    # Сканирование одного IP
    echo "[*] Сканирование IP ${PREFIX}.${SUBNET}.${HOST}"
    scan_ip "${PREFIX}.${SUBNET}.${HOST}"
    
else
    echo "Ошибка: Некорректная комбинация аргументов" >&2
    exit 1
fi

echo "[*] Сканирование завершено"

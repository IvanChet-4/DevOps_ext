#!/bin/bash

# Проверка прав root
if [[ $EUID -ne 0 ]]; then
    echo "Ошибка: Скрипт должен запускаться с правами root" >&2
    exit 1
fi

# Проверка количества аргументов
if [[ $# -ne 1 ]]; then
    echo "Использование: $0 <INTERFACE>" >&2
    echo "Пример: $0 eth0" >&2
    exit 1
fi

INTERFACE="$1"

# Функция для проверки IP-адреса
validate_ip() {
    local ip=$1
    if [[ ! $ip =~ ^[0-9]{1,3}$ ]] || [[ $ip -lt 0 ]] || [[ $ip -gt 255 ]]; then
        return 1
    fi
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

# Функция для получения информации о подсети
get_network_info() {
    local interface=$1
    
    # Используем ip a для получения информации
    local network_info
    network_info=$(ip -4 addr show "$interface" 2>/dev/null | grep -oP 'inet \K[0-9.]+/[0-9]+')
    
    if [[ -z "$network_info" ]]; then
        echo "Ошибка: Не удалось получить информацию о сети для интерфейса $interface" >&2
        return 1
    fi
    
    echo "$network_info"
    return 0
}

# Функция для расчета диапазона IP-адресов
calculate_ip_range() {
    local cidr=$1
    
    IFS='/' read -r ip_addr mask <<< "$cidr"
    
    # Преобразуем IP в числовой формат
    IFS='.' read -r ip1 ip2 ip3 ip4 <<< "$ip_addr"
    
    # Рассчитываем сетевой адрес и широковещательный
    local network_ip
    local broadcast_ip
    
    case $mask in
        24)
            network_ip="${ip1}.${ip2}.${ip3}.0"
            broadcast_ip="${ip1}.${ip2}.${ip3}.255"
            ;;
        16)
            network_ip="${ip1}.${ip2}.0.0"
            broadcast_ip="${ip1}.${ip2}.255.255"
            ;;
        8)
            network_ip="${ip1}.0.0.0"
            broadcast_ip="${ip1}.255.255.255"
            ;;
        *)
            # Для других масок используем ipcalc если доступен, или упрощенный расчет
            if command -v ipcalc &>/dev/null; then
                local ipcalc_output
                ipcalc_output=$(ipcalc "$cidr")
                network_ip=$(echo "$ipcalc_output" | grep -oP 'Network:\s+\K[0-9.]+')
                broadcast_ip=$(echo "$ipcalc_output" | grep -oP 'Broadcast:\s+\K[0-9.]+')
            else
                echo "Предупреждение: Используется упрощенный расчет для маски /$mask" >&2
                network_ip="$ip_addr"
                broadcast_ip="$ip_addr"
            fi
            ;;
    esac
    
    echo "$network_ip $broadcast_ip"
}

# Функция для сканирования одного IP
scan_ip() {
    local ip=$1
    echo "[*] Проверка IP: $ip"
    if arping -c 2 -w 1 -i "$INTERFACE" "$ip" 2>/dev/null | grep -q "reply"; then
        echo "[+] Хост $ip активен"
    fi
}

# Основная функция сканирования
perform_scan() {
    local start_ip=$1
    local end_ip=$2
    
    IFS='.' read -r s1 s2 s3 s4 <<< "$start_ip"
    IFS='.' read -r e1 e2 e3 e4 <<< "$end_ip"
    
    # Простой перебор IP в диапазоне
    for ((a=s1; a<=e1; a++)); do
        for ((b=s2; b<=e2; b++)); do
            for ((c=s3; c<=e3; c++)); do
                for ((d=s4; d<=e4; d++)); do
                    # Пропускаем сетевой и широковещательный адреса
                    if [[ $a -eq $s1 && $b -eq $s2 && $c -eq $s3 && $d -eq $s4 ]]; then
                        continue # сетевой адрес
                    fi
                    if [[ $a -eq $e1 && $b -eq $e2 && $c -eq $e3 && $d -eq $e4 ]]; then
                        continue # широковещательный адрес
                    fi
                    
                    scan_ip "${a}.${b}.${c}.${d}"
                done
            done
        done
    done
}

# Проверка интерфейса
if ! validate_interface "$INTERFACE"; then
    echo "Ошибка: Интерфейс $INTERFACE не существует" >&2
    exit 1
fi

# Получаем информацию о сети
if ! network_info=$(get_network_info "$INTERFACE"); then
    exit 1
fi

echo "[*] Обнаружена сеть: $network_info на интерфейсе $INTERFACE"

# Рассчитываем диапазон IP
ip_range=$(calculate_ip_range "$network_info")
if [[ -z "$ip_range" ]]; then
    echo "Ошибка: Не удалось рассчитать диапазон IP" >&2
    exit 1
fi

read -r start_ip end_ip <<< "$ip_range"

echo "[*] Диапазон сканирования: $start_ip - $end_ip"
echo "[*] Начало сканирования..."

# Выполняем сканирование
perform_scan "$start_ip" "$end_ip"

echo "[*] Сканирование завершено.${ip4}"

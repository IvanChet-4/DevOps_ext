#!/usr/bin/env bash
# dev_monitor.sh
# Показать содержимое /proc/bus/input/devices и список /dev/input/event*

set -euo pipefail

# --- Функции ----------------------------------------------------------
print_section() {
    echo
    printf '%50s\n' | tr ' ' '-'
    printf " %s\n" "$1"
    printf '%50s\n' | tr ' ' '-'
}

# --- Основной код -----------------------------------------------------
print_section "Устройства в /proc/bus/input/devices"
cat /proc/bus/input/devices

print_section "Файлы устройств /dev/input/event*"
ls -l /dev/input/event* 2>/dev/null || echo "Нет ни одного /dev/input/event*"

print_section "Готово"

====================================================

#!/usr/bin/env bash
# dev_monitor.sh
# Показать и «разобрать» содержимое /proc/bus/input/devices и список /dev/input/event*

set -euo pipefail

# --- Функции ----------------------------------------------------------
print_section() {
    echo
    printf '%50s\n' | tr ' ' '-'
    printf " %s\n" "$1"
    printf '%50s\n' | tr ' ' '-'
}

# --- Основной код -----------------------------------------------------
print_section "Устройства в /proc/bus/input/devices"
cat /proc/bus/input/devices

print_section "Файлы устройств /dev/input/event*"
ls -l /dev/input/event* 2>/dev/null || echo "Нет ни одного /dev/input/event*"

print_section "Разбор устройств по столбцам"
# Построчно обрабатываем /proc/bus/input/devices
while IFS= read -r line; do
    # Пропускаем пустые строки
    [[ -z "$line" ]] && continue

    # Определяем тип строки по префиксу
    case "$line" in
        I*)  # Информация об устройстве
            bus=$(echo "$line" | awk '{print $2}')
            vendor=$(echo "$line" | awk -F= '{print $2}' | awk '{print $1}')
            product=$(echo "$line" | awk -F= '{print $3}' | awk '{print $1}')
            version=$(echo "$line" | awk -F= '{print $4}')
            echo "  Bus=$bus  Vendor=$vendor  Product=$product  Version=$version"
            ;;
        N*)  # Имя устройства
            name=$(echo "$line" | sed 's/N: Name="//; s/"//')
            echo "  Name: $name"
            ;;
        P*)  # Возможности (phys)
            phys=$(echo "$line" | sed 's/P: Phys=//')
            echo "  Phys: $phys"
            ;;
        S*)  # Системные свойства
            sysprops=$(echo "$line" | sed 's/S: Sysfs=//')
            echo "  Sysfs: $sysprops"
            ;;
        H*)  # Обработчики (handlers)
            handlers=$(echo "$line" | sed 's/H: Handlers=//')
            echo "  Handlers: $handlers"
            ;;
        B*)  # Битовые маски
            key=$(echo "$line" | awk '{print $2}')
            value=$(echo "$line" | cut -d' ' -f3-)
            printf "  %-10s %s\n" "$key" "$value"
            ;;
        *)   # Всё остальное
            echo "  $line"
            ;;
    esac
done < /proc/bus/input/devices

print_section "Разбор /dev/input/event*"
# Проходим по каждому файлу /dev/input/event*
for dev in /dev/input/event*; do
    [[ ! -e "$dev" ]] && continue   # если файлов нет, выйдем

    # Получаем информацию о файле
    perms=$(stat -c '%A' "$dev")
    owner=$(stat -c '%U:%G' "$dev")
    major=$(stat -c '%t' "$dev")
    minor=$(stat -c '%T' "$dev")

    # Убираем ведущие нули у major/minor
    major=$((16#$major))
    minor=$((16#$minor))

    printf '%-20s %12s %10s %3d:%-3d\n' "$dev" "$perms" "$owner" "$major" "$minor"
done

print_section "Готово"

====================================================

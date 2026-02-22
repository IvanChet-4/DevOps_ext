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

#!/usr/bin/env bash
# dev_monitor.sh
# Показать и «разобрать» содержимое /proc/bus/input/devices и список /dev/input/event*
# С логированием: фиксируем время запуска и добавляются только новые устройства.

set -euo pipefail

# --- Конфигурация -------------------------------------------------------
LOGFILE="$HOME/.local/share/dev_monitor.log"      # путь к лог-файлу
mkdir -p "$(dirname "$LOGFILE")"

# --- Функции ----------------------------------------------------------
print_section() {
    echo
    printf '%50s\n' | tr ' ' '-'
    printf " %s\n" "$1"
    printf '%50s\n' | tr ' ' '-'
}

log() {
    # $1 — уровень (INFO|WARN|ERROR), $2 — сообщение
    printf '%s [%s] %s\n' "$(date '+%F %T')" "$1" "$2" >>"$LOGFILE"
}

# Снимок «подписи» устройства: Vendor, Product, Name
device_key() {
    awk -v RS='' '
    /Vendor/ && /Product/ && /Name/ {
        match($0, /Vendor=([0-9a-f]+)/, v)
        match($0, /Product=([0-9a-f]+)/, p)
        match($0, /Name="([^"]+)"/, n)
        print v[1]":"p[1]":"n[1]
    }
    ' "$1"
}

# --- Лог старта --------------------------------------------------------
log INFO "Скрипт запущен"

# --- Основной код -----------------------------------------------------
print_section "Устройства в /proc/bus/input/devices"
cat /proc/bus/input/devices

print_section "Файлы устройств /dev/input/event*"
ls -l /dev/input/event* 2>/dev/null || echo "Нет ни одного /dev/input/event*"

print_section "Разбор устройств по столбцам"
# Сначала соберём «подписи» текущих устройств
TMP_CURRENT=$(mktemp)
device_key /proc/bus/input/devices >"$TMP_CURRENT"

# Затем загрузим уже сохранённые «подписи»
KNOWN_FILE="$HOME/.local/share/known_devices.txt"
touch "$KNOWN_FILE"
TMP_KNOWN=$(mktemp)
sort -u "$KNOWN_FILE" >"$TMP_KNOWN"

# Построчное чтение и вывод
while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    case "$line" in
        I*)  bus=$(echo "$line" | awk '{print $2}')
             vendor=$(echo "$line" | awk -F= '{print $2}' | awk '{print $1}')
             product=$(echo "$line" | awk -F= '{print $3}' | awk '{print $1}')
             version=$(echo "$line" | awk -F= '{print $4}')
             echo "  Bus=$bus  Vendor=$vendor  Product=$product  Version=$version"
             ;;
        N*)  name=$(echo "$line" | sed 's/N: Name="//; s/"//')
             echo "  Name: $name"
             ;;
        P*)  phys=$(echo "$line" | sed 's/P: Phys=//')
             echo "  Phys: $phys"
             ;;
        S*)  sysprops=$(echo "$line" | sed 's/S: Sysfs=//')
             echo "  Sysfs: $sysprops"
             ;;
        H*)  handlers=$(echo "$line" | sed 's/H: Handlers=//')
             echo "  Handlers: $handlers"
             ;;
        B*)  key=$(echo "$line" | awk '{print $2}')
             value=$(echo "$line" | cut -d' ' -f3-)
             printf "  %-10s %s\n" "$key" "$value"
             ;;
        *)   echo "  $line" ;;
    esac
done < /proc/bus/input/devices

# --- Определение новых устройств и логирование -------------------------
print_section "Анализ новых устройств"

NEW_COUNT=0
while IFS= read -r key; do
    if [[ -n "$key" ]] && ! grep -Fxq "$key" "$TMP_KNOWN"; then
        echo "  → Новое устройство: $key"
        log INFO "Обнаружено новое устройство: $key"
        echo "$key" >>"$KNOWN_FILE"
        ((NEW_COUNT++))
    fi
done <"$TMP_CURRENT"

if (( NEW_COUNT == 0 )); then
    echo "  Новых устройств не обнаружено"
    log INFO "Новых устройств не обнаружено"
fi

# --- Разбор /dev/input/event* -----------------------------------------
print_section "Разбор /dev/input/event*"
for dev in /dev/input/event*; do
    [[ ! -e "$dev" ]] && continue
    perms=$(stat -c '%A' "$dev")
    owner=$(stat -c '%U:%G' "$dev")
    major=$(stat -c '%t' "$dev")
    minor=$(stat -c '%T' "$dev")
    major=$((16#$major))
    minor=$((16#$minor))
    printf '%-20s %12s %10s %3d:%-3d\n' "$dev" "$perms" "$owner" "$major" "$minor"
done

print_section "Готово"
log INFO "Скрипт завершён"

====================================================

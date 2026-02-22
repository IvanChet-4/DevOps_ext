#!/usr/bin/env bash
# dev_monitor.sh – показывает список ввода-устройств и логирует новые.
# Использование:
#   ./dev_monitor.sh           – список сейчас
#   ./dev_monitor.sh --daemon  – демон, логирует только новые


readonly LOG_FILE="/var/log/usb_monitor.log"
readonly STATE_FILE="/var/run/usb_monitor_state"
readonly INPUT_DIR="/proc/bus/input"

# Убедиться, что директория существует
[[ -d "$INPUT_DIR" ]] || { echo "Нет $INPUT_DIR"; exit 1; }

# Получаем список устройств в формате "name  handlers  bus  vendor  product"
get_devices() {
    local file="$INPUT_DIR/devices"
    awk '
        /^N:/                { name=$0; sub(/^N: Name=/,"",name); gsub(/"/,"",name) }
        /^H:/                { handlers=$0; sub(/^H: Handlers=/,"",handlers) }
        /^B:/ && /BUS=001/  { bus=$0; sub(/^B: /,"",bus) }
        /^S:/                { vendor=$0; sub(/^S: Sysfs=.+\/vendor/,"",vendor); sub(/ .*$/,"",vendor) }
        /^S:/                { product=$0; sub(/^S: Sysfs=.*\/product/,"",product); sub(/ .*$/,"",product) }
        /^$/                 { if (name!="") print name "|" handlers "|" bus "|" vendor "|" product; name=""; handlers=""; bus=""; vendor=""; product="" }
    ' "$file"
}

# Записываем в лог только новые устройства
log_new() {
    local now
    now=$(date '+%F %T')
    while IFS= read -r line; do
        if ! grep -qxF "$line" "$STATE_FILE" 2>/dev/null; then
            echo "$line" >> "$STATE_FILE"
            echo "[$now] NEW DEVICE: $line" >> "$LOG_FILE"
        fi
    done
}

case "$1" in
    --daemon)
        echo "Запускаюсь в фоновом режиме (PID $$)"
        # Очищаем старый state, чтобы не учитывать предыдущие устройства
        > "$STATE_FILE"
        # Первичное заполнение
        get_devices | log_new
        # Наблюдение за каталогом (только создание/удаление)
        inotifywait -m -e create,delete "$INPUT_DIR" --format '%w%f' |
        while read -r _; do
            get_devices | log_new
        done
        ;;
    *)
        # Однократный вывод
        echo "Текущие устройства ввода:"
        get_devices | column -t -s '|'
        ;;
esac

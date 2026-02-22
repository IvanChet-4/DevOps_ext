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

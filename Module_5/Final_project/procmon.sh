#!/usr/bin/env bash
# procmon.sh – мониторинг новых процессов в /proc/ (записывает в лог только появившиеся процессы за последние 5 минут).
LOG_DIR="/var/log/procmon"
LOG_FILE="${LOG_DIR}/procmon.log"
STATE_FILE="${LOG_DIR}/.last_pids"      # кэш PID'ов с предыдущего запуска
INTERVAL_SEC=300                        
# Создаём директорию, если её нет
[[ -d $LOG_DIR ]] || mkdir -p "$LOG_DIR"
# Список файлов /proc/<pid>/…, данные которых сохраняем
PARAMS=(status cmdline environ limits)
# Вспомогательная функция: безопасное чтение файлов
read_proc() {
  local path=$1
  [[ -r $path ]] && cat "$path" 2>/dev/null || echo "N/A"
}
# Формирование таблицы
print_header() {
  printf "%-7s %-30s %-20s %-20s %-20s %-20s\n" \
         "PID" "Name" "${PARAMS[@]}"
}
print_row() {
  local pid=$1
  local name=$2
  local row=""
  for p in "${PARAMS[@]}"; do
    data=$(read_proc "/proc/$pid/$p")
    # Статус берём первую строку (Name:)
    [[ $p == "status" ]] && data=$(echo "$data" | grep '^Name:' | cut -f2)
    # cmdline и environ – разделяем нули пробелами
    [[ $p =~ ^(cmdline|environ)$ ]] && data=$(tr '\0' ' ' <<<"$data")
    # Обрезаем длинные строки
    row+="$(printf "%-20s" "${data:0:20}") "
  done
  printf "%-7s %-30s %s\n" "$pid" "$name" "$row"
}
# Текущее время
NOW=$(date '+%F %T')
# Записываем заголовок
{
  echo "=== $NOW ==="
  print_header
} >>"$LOG_FILE"
# Список всех числовых PID-директорий
mapfile -t CURRENT_PIDS < <(find /proc -maxdepth 1 -type d -regex '.*/[0-9]+$' -printf '%f\n')
# Загружаем список PID'ов с предыдущего запуска
[[ -f $STATE_FILE ]] && mapfile -t LAST_PIDS <"$STATE_FILE" || LAST_PIDS=()
# Определяем новые PID'ы
NEW_PIDS=()
for pid in "${CURRENT_PIDS[@]}"; do
  [[ " ${LAST_PIDS[*]} " =~ " $pid " ]] || NEW_PIDS+=("$pid")
done

# Обрабатываем новые процессы
for pid in "${NEW_PIDS[@]}"; do
  exe_link="/proc/$pid/exe"
  [[ -r $exe_link ]] || continue         # процесс мог завершиться  name=$(readlink -f "$exe_link" | xargs basename 2>/dev/null || echo "N/A")
  print_row "$pid" "$name"
done >>"$LOG_FILE"
# Сохраняем актуальный список PID'ов
printf '%s\n' "${CURRENT_PIDS[@]}" >"$STATE_FILE"

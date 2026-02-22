#!/usr/bin/env bash

mapfile -t CURRENT_PIDS < <(
  find /proc -maxdepth 1 -type d -regex '.*/[0-9]+' -printf '%f\n'
)

# Выводим результат
printf '%s\n' "${CURRENT_PIDS[@]}"

====================================================

#!/usr/bin/env bash
mapfile -t CURRENT_PIDS < <(
  find /proc -maxdepth 1 -type d -regex '.*/[0-9]+' -printf '%f\n'
)

for pid in "${CURRENT_PIDS[@]}"; do
  exe_path="/proc/$pid/exe"
  if [[ -r "$exe_path" ]]; then
    # basename оставляет только последний компонент пути
    exe_name=$(basename "$(readlink -f "$exe_path")")
  else
    exe_name="<нет доступа>"
  fi
  printf '%-6s %s\n' "$pid" "$exe_name"
done

====================================================

#!/usr/bin/env bash
# Утилита просмотра информации о процессах из /proc

# Считываем список PID
mapfile -t CURRENT_PIDS < <(
  find /proc -maxdepth 1 -type d -regex '.*/[0-9]+' -printf '%f\n' | sort -n
)

# Выводим PID и соответствующий exe
for pid in "${CURRENT_PIDS[@]}"; do
  exe_path="/proc/$pid/exe"
  if [[ -r "$exe_path" ]]; then
    exe_name=$(basename "$(readlink -f "$exe_path")")
  else
    exe_name="<нет доступа>"
  fi
  printf '%-6s %s\n' "$pid" "$exe_name"
done

echo
echo "Введите PID для просмотра детальной информации (q для выхода): "

while true; do
  read -r TARGET_PID
  [[ $TARGET_PID == "q" ]] && break
  [[ ! " ${CURRENT_PIDS[*]} " =~ " $TARGET_PID " ]] && echo "Неверный PID" && continue

  # Меню выбора параметров
  echo "Выберите параметр:"
  echo "1) cmdline  2) environ  3) limits  4) mounts"
  echo "5) status   6) cwd      7) fd      8) fdinfo"
  echo "9) root     0) все параметры"
  echo -n "Ваш выбор: "

  read -r choice
  echo

  # Функция для безопасного вывода содержимого
  safe_cat() {
    local file=$1
    if [[ -r "$file" ]]; then
      cat "$file"
    else
      echo "<нет доступа к $file>"
    fi
  }

  case $choice in
    1|cmdline)  safe_cat "/proc/$TARGET_PID/cmdline" | tr '\0' ' ' ;;
    2|environ)  safe_cat "/proc/$TARGET_PID/environ" | tr '\0' '\n' ;;
    3|limits)   safe_cat "/proc/$TARGET_PID/limits" ;;
    4|mounts)   safe_cat "/proc/$TARGET_PID/mounts" ;;
    5|status)   safe_cat "/proc/$TARGET_PID/status" ;;
    6|cwd)      readlink -f "/proc/$TARGET_PID/cwd" ;;
    7|fd)
      echo "Открытые файловые дескрипторы:"
      for fd in /proc/$TARGET_PID/fd/*; do
        [[ -e "$fd" ]] && printf "%-4s -> %s\n" "$(basename "$fd")" "$(readlink -f "$fd")"
      done
      ;;
    8|fdinfo)
      echo "Информация о fd:"
      for fd in /proc/$TARGET_PID/fdinfo/*; do
        [[ -e "$fd" ]] && echo "--- $(basename "$fd") ---" && cat "$fd"
      done
      ;;
    9|root)     readlink -f "/proc/$TARGET_PID/root" ;;
    0|all)
      for param in cmdline environ limits mounts status; do
        echo "=== $param ==="
        safe_cat "/proc/$TARGET_PID/$param"
        echo
      done
      echo "=== cwd ==="; readlink -f "/proc/$TARGET_PID/cwd"; echo
      echo "=== root ==="; readlink -f "/proc/$TARGET_PID/root"; echo
      ;;
    *) echo "Неверный выбор";;
  esac
  echo
  echo "Введите PID или q для выхода: "
done

====================================================

#!/usr/bin/env bash
# Утилита просмотра информации о процессах из /proc

# Считываем список PID
mapfile -t CURRENT_PIDS < <(
  find /proc -maxdepth 1 -type d -regex '.*/[0-9]+' -printf '%f\n' | sort -n
)

# Выводим PID и соответствующий exe
for pid in "${CURRENT_PIDS[@]}"; do
  exe_path="/proc/$pid/exe"
  if [[ -r "$exe_path" ]]; then
    exe_name=$(basename "$(readlink -f "$exe_path")")
  else
    exe_name="<нет доступа>"
  fi
  printf '%-6s %s\n' "$pid" "$exe_name"
done

echo
echo "Введите PID для просмотра детальной информации (q – выход, t – таблица): "

# Функция вывода таблицы
print_table() {
  printf '%-6s %-20s %10s %8s %8s %s\n' \
         "PID" "Name" "VmRSS(KB)" "Threads" "FD-count" "CapBnd"
  printf '%.0s-' {1..80}; echo

  for pid in "${CURRENT_PIDS[@]}"; do
    # Name
    exe_path="/proc/$pid/exe"
    [[ -r "$exe_path" ]] && name=$(basename "$(readlink -f "$exe_path")") || name="<нет доступа>"
    name=${name:0:20}

    # VmRSS
    vmrss=$(awk '/VmRSS:/ {print $2}' "/proc/$pid/status" 2>/dev/null || echo 0)

    # Threads
    threads=$(awk '/Threads:/ {print $2}' "/proc/$pid/status" 2>/dev/null || echo 0)

    # FD-count
    fd_dir="/proc/$pid/fd"
    fd_count=0
    [[ -d "$fd_dir" ]] && fd_count=$(ls -1 "$fd_dir" 2>/dev/null | wc -l)

    # CapBnd
    capbnd=$(awk '/CapBnd:/ {print $2}' "/proc/$pid/status" 2>/dev/null || echo 0)

    printf '%-6s %-20s %10s %8s %8s %s\n' \
           "$pid" "$name" "$vmrss" "$threads" "$fd_count" "$capbnd"
  done
  echo
}

while true; do
  read -r TARGET_PID
  case "$TARGET_PID" in
    q) break ;;
    t)
      print_table
      echo "Введите PID или q для выхода, t для таблицы: "
      continue
      ;;
  esac

  [[ ! " ${CURRENT_PIDS[*]} " =~ " $TARGET_PID " ]] && echo "Неверный PID" && continue

  # Меню выбора параметров
  echo "Выберите параметр:"
  echo "1) cmdline  2) environ  3) limits  4) mounts"
  echo "5) status   6) cwd      7) fd      8) fdinfo"
  echo "9) root     0) все параметры"
  echo -n "Ваш выбор: "

  read -r choice
  echo

  # Функция для безопасного вывода содержимого
  safe_cat() {
    local file=$1
    if [[ -r "$file" ]]; then
      cat "$file"
    else
      echo "<нет доступа к $file>"
    fi
  }

  case $choice in
    1|cmdline)  safe_cat "/proc/$TARGET_PID/cmdline" | tr '\0' ' ' ;;
    2|environ)  safe_cat "/proc/$TARGET_PID/environ" | tr '\0' '\n' ;;
    3|limits)   safe_cat "/proc/$TARGET_PID/limits" ;;
    4|mounts)   safe_cat "/proc/$TARGET_PID/mounts" ;;
    5|status)   safe_cat "/proc/$TARGET_PID/status" ;;
    6|cwd)      readlink -f "/proc/$TARGET_PID/cwd" ;;
    7|fd)
      echo "Открытые файловые дескрипторы:"
      for fd in /proc/$TARGET_PID/fd/*; do
        [[ -e "$fd" ]] && printf "%-4s -> %s\n" "$(basename "$fd")" "$(readlink -f "$fd")"
      done
      ;;
    8|fdinfo)
      echo "Информация о fd:"
      for fd in /proc/$TARGET_PID/fdinfo/*; do
        [[ -e "$fd" ]] && echo "--- $(basename "$fd") ---" && cat "$fd"
      done
      ;;
    9|root)     readlink -f "/proc/$TARGET_PID/root" ;;
    0|all)
      for param in cmdline environ limits mounts status; do
        echo "=== $param ==="
        safe_cat "/proc/$TARGET_PID/$param"
        echo
      done
      echo "=== cwd ==="; readlink -f "/proc/$TARGET_PID/cwd"; echo
      echo "=== root ==="; readlink -f "/proc/$TARGET_PID/root"; echo
      ;;
    *) echo "Неверный выбор";;
  esac
  echo
  echo "Введите PID или q для выхода, t для таблицы: "
done

====================================================

#!/usr/bin/env bash
# Утилита просмотра информации о процессах из /proc
# Логирование: только новые процессы, время запуска скрипта

# Каталог и имя лог-файла
LOG_DIR="${HOME}/.proc_watcher"
LOG_FILE="${LOG_DIR}/new_procs.log"
mkdir -p "$LOG_DIR"

# Записываем время запуска скрипта
SCRIPT_START=$(date '+%F %T')
echo "=== Скрипт запущен: $SCRIPT_START ===" >>"$LOG_FILE"

# Считываем список PID, которые уже были до запуска скрипта
mapfile -t PIDS_BEFORE < <(
  find /proc -maxdepth 1 -type d -regex '.*/[0-9]+' -printf '%f\n' | sort -n
)

# Считываем актуальный список PID
mapfile -t CURRENT_PIDS < <(
  find /proc -maxdepth 1 -type d -regex '.*/[0-9]+' -printf '%f\n' | sort -n
)

# Определяем новые процессы (которые появились после запуска скрипта)
declare -A OLD_PIDS_MAP
for p in "${PIDS_BEFORE[@]}"; do OLD_PIDS_MAP[$p]=1; done

for pid in "${CURRENT_PIDS[@]}"; do
  [[ -z "${OLD_PIDS_MAP[$pid]}" ]] || continue          # процесс уже был
  exe_path="/proc/$pid/exe"
  if [[ -r "$exe_path" ]]; then
    exe_name=$(basename "$(readlink -f "$exe_path")")
  else
    exe_name="<нет доступа>"
  fi
  echo "$SCRIPT_START NEW $pid $exe_name" >>"$LOG_FILE"
done

# === далее исходный функционал без изменений ===

# Выводим PID и соответствующий exe
for pid in "${CURRENT_PIDS[@]}"; do
  exe_path="/proc/$pid/exe"
  if [[ -r "$exe_path" ]]; then
    exe_name=$(basename "$(readlink -f "$exe_path")")
  else
    exe_name="<нет доступа>"
  fi
  printf '%-6s %s\n' "$pid" "$exe_name"
done

echo
echo "Введите PID для просмотра детальной информации (q – выход, t – таблица): "

# Функция вывода таблицы
print_table() {
  printf '%-6s %-20s %10s %8s %8s %s\n' \
         "PID" "Name" "VmRSS(KB)" "Threads" "FD-count" "CapBnd"
  printf '%.0s-' {1..80}; echo

  for pid in "${CURRENT_PIDS[@]}"; do
    # Name
    exe_path="/proc/$pid/exe"
    [[ -r "$exe_path" ]] && name=$(basename "$(readlink -f "$exe_path")") || name="<нет доступа>"
    name=${name:0:20}

    # VmRSS
    vmrss=$(awk '/VmRSS:/ {print $2}' "/proc/$pid/status" 2>/dev/null || echo 0)

    # Threads
    threads=$(awk '/Threads:/ {print $2}' "/proc/$pid/status" 2>/dev/null || echo 0)

    # FD-count
    fd_dir="/proc/$pid/fd"
    fd_count=0
    [[ -d "$fd_dir" ]] && fd_count=$(ls -1 "$fd_dir" 2>/dev/null | wc -l)

    # CapBnd
    capbnd=$(awk '/CapBnd:/ {print $2}' "/proc/$pid/status" 2>/dev/null || echo 0)

    printf '%-6s %-20s %10s %8s %8s %s\n' \
           "$pid" "$name" "$vmrss" "$threads" "$fd_count" "$capbnd"
  done
  echo
}

while true; do
  read -r TARGET_PID
  case "$TARGET_PID" in
    q) break ;;
    t)
      print_table
      echo "Введите PID или q для выхода, t для таблицы: "
      continue
      ;;
  esac

  [[ ! " ${CURRENT_PIDS[*]} " =~ " $TARGET_PID " ]] && echo "Неверный PID" && continue

  # Меню выбора параметров
  echo "Выберите параметр:"
  echo "1) cmdline  2) environ  3) limits  4) mounts"
  echo "5) status   6) cwd      7) fd      8) fdinfo"
  echo "9) root     0) все параметры"
  echo -n "Ваш выбор: "

  read -r choice
  echo

  # Функция для безопасного вывода содержимого
  safe_cat() {
    local file=$1
    if [[ -r "$file" ]]; then
      cat "$file"
    else
      echo "<нет доступа к $file>"
    fi
  }

  case $choice in
    1|cmdline)  safe_cat "/proc/$TARGET_PID/cmdline" | tr '\0' ' ' ;;
    2|environ)  safe_cat "/proc/$TARGET_PID/environ" | tr '\0' '\n' ;;
    3|limits)   safe_cat "/proc/$TARGET_PID/limits" ;;
    4|mounts)   safe_cat "/proc/$TARGET_PID/mounts" ;;
    5|status)   safe_cat "/proc/$TARGET_PID/status" ;;
    6|cwd)      readlink -f "/proc/$TARGET_PID/cwd" ;;
    7|fd)
      echo "Открытые файловые дескрипторы:"
      for fd in /proc/$TARGET_PID/fd/*; do
        [[ -e "$fd" ]] && printf "%-4s -> %s\n" "$(basename "$fd")" "$(readlink -f "$fd")"
      done
      ;;
    8|fdinfo)
      echo "Информация о fd:"
      for fd in /proc/$TARGET_PID/fdinfo/*; do
        [[ -e "$fd" ]] && echo "--- $(basename "$fd") ---" && cat "$fd"
      done
      ;;
    9|root)     readlink -f "/proc/$TARGET_PID/root" ;;
    0|all)
      for param in cmdline environ limits mounts status; do
        echo "=== $param ==="
        safe_cat "/proc/$TARGET_PID/$param"
        echo
      done
      echo "=== cwd ==="; readlink -f "/proc/$TARGET_PID/cwd"; echo
      echo "=== root ==="; readlink -f "/proc/$TARGET_PID/root"; echo
      ;;
    *) echo "Неверный выбор";;
  esac
  echo
  echo "Введите PID или q для выхода, t для таблицы: "
done

====================================================

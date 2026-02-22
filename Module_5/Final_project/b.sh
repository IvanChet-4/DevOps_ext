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

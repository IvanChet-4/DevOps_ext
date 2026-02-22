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

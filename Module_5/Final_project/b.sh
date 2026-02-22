#!/usr/bin/env bash

mapfile -t CURRENT_PIDS < <(
  find /proc -maxdepth 1 -type d -regex '.*/[0-9]+' -printf '%f\n'
)

# Выводим результат
printf '%s\n' "${CURRENT_PIDS[@]}"

====================================================

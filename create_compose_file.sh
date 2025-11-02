#!/bin/bash

if [ $# -ne 2 ]; then
  echo "Error: This script requires two arguments: bench name and deployment directory"
  exit 1
fi

bench_name="$1"
deployment_dir="$2"

overrides=(overrides/*)
choices=()

main() {
  while true; do
    echo -e "\nAvailable Docker Compose overrides:"
    for i in "${!overrides[@]}"; do
      selected="${choices[i]:- }"
      printf " %s) [%s] %s\n" "$((i+1))" "$selected" "${overrides[i]}"
    done

    read -p "Select overrides: " num
    [[ -z "$num" ]] && break
    if [[ "$num" =~ ^[0-9]+$ ]] && (( num > 0 && num <= ${#overrides[@]} )); then
      idx=$((num-1))
      if [[ -n "${choices[idx]}" ]]; then
        choices[idx]=""
      else
        choices[idx]="x"
      fi
    else
      echo "Invalid selection."
    fi
  done

  echo "You selected:"
  for i in "${!choices[@]}"; do
    [[ "${choices[i]}" == "x" ]] && echo "${overrides[i]}"
  done

  args=(-f "compose.yaml")
  for i in "${!choices[@]}"; do
    [[ "${choices[i]}" == "x" ]] && args+=(-f "${overrides[i]}")
  done

  docker compose --env-file "$deployment_dir/$bench_name.env" "${args[@]}" config > "$deployment_dir/$bench_name.yaml"

  echo "Created Docker compose file at $deployment_dir/$bench_name.yaml"

  read -p "Would you like to view the compose file? [Y/n]: " cat_compose
  cat_compose=${cat_compose:- y}
  cat_compose=$(echo "$cat_compose" | tr '[:upper:]' '[:lower:]')

  case "$cat_compose" in
    y|yes)
      echo -e "\nContents of $deployment_dir/$bench_name.yaml compose file:\n"
      cat "$deployment_dir/$bench_name.yaml"
      ;;
    *)
      ;;
  esac
}

main
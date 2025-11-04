#!/bin/bash

set -e

validate_bench_name() {
    local name="$1"
    if [[ "$name" =~ ^[a-zA-Z0-9_.-]+$ ]]; then
        return 0
    else
        return 1
    fi
}

parse_arguments() {
  local bench_name=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -b|--bench-name)
        bench_name="$2"
        shift 2
        ;;
      *)
        echo "Unknown option: $1"
        exit 1
        ;;
    esac
  done

  if [[ -z "$bench_name" ]]; then
    while true; do
      read -p "Enter the name of your Frappe bench: " bench_name

      if validate_bench_name "$bench_name"; then
        break
      else
        echo "Invalid bench name."
      fi
    done
  else
    if ! validate_bench_name "$bench_name"; then
      echo "Invalid bench name."
      exit 1
    fi
  fi

  echo "$bench_name"
}

handle_environtment_file() {
  local bench_name="$1"
  local deployment_dir="$2"
  local custom_image_details="${3:-}"

  while true; do
    read -p "Do you want to create an environment file? [Y/n] " create_env
    create_env=${create_env:-y}
    create_env=$(echo "$create_env" | tr '[:upper:]' '[:lower:]')

    case $create_env in
      y|yes)
        ./create_environment_file.sh "$bench_name" "$deployment_dir" "$custom_image_details"
        break
        ;;
      n|no)
        while true; do
          read -p "Enter path of environment file: " env_file

          if [ -f "$env_file" ] && [ -r "$env_file" ]; then
            cp "$env_file" "$deployment_dir/$bench_name.env"
            echo "Environment file copied to: $deployment_dir/$bench_name.env"
            break
          else
            echo "Invalid file"
          fi
        done
        ;;
      *)
        echo "Invalid input"
        ;;
    esac
  done
}

main() {
  bench_name=$(parse_arguments "$@")
  deployment_dir=~/deployments/"$bench_name"

  mkdir -p "$deployment_dir"

  echo "Bench deployment directory created: $deployment_dir"

  while true; do
    read -p "Do you want to create a custom image? [Y/n]: " create_image
    create_image=${create_image:-y}
    create_image=$(echo "$create_image" | tr '[:upper:]' '[:lower:]')

    case "$create_image" in
      y|yes)
        ./create_apps_json.sh "$bench_name" "$deployment_dir"

        ./create_custom_image.sh "$bench_name" "$deployment_dir"

        image_detail_file="$deployment_dir/${bench_name}_image_details.txt"

        custom_image_details=""

        if [ -f "$image_details_file" ]; then
          custom_image_details=$(grep "New Image:" "$image_detail_file" | cut -d' ' -f3)
        fi

        handle_environtment_file "$bench_name" "$deployment_dir" "$custom_image_details"

        ./create_compose_file.sh "$bench_name" "$deployment_dir"
        break
        ;;
      n|no)
        handle_environtment_file "$bench_name" "$deployment_dir" ""

        ./create_compose_file.sh "$bench_name" "$deployment_dir"
        break
        ;;
      *)
        echo "Invalid input."
        ;;
    esac
  done
}

main "$@"
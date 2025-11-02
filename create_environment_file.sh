#!/bin/bash

if [ $# -ne 3 ]; then
  echo "Error: this script requires three arguments: bench_name, deployment_dir, custom_image_details"
  exit 1
fi

bench_name="$1"
deployment_dir="$2"
custom_image_details="${3:-}"

template_env_file="example.env"
output_env_file="$deployment_dir/$bench_name.env"

validate_env_template() {
    if [ ! -f "$template_env_file" ]; then
        echo "Error: Template environment file $template_env_file not found."
        return 1
    fi
    return 0
}

sanitize_name() {
    local name="$1"
    # Replace dots with underscores
    echo "$name" | sed 's/\./_/g'
}

main() {
  if ! validate_env_template; then
    exit 1
  fi

  cp "$template_env_file" "$output_env_file"

  sanitized_bench_name=$(sanitize_name "$bench_name")

  sed -i "s/^ROUTER=.*/ROUTER=$sanitized_bench_name/" "$output_env_file"
  sed -i "s/^BENCH_NETWORK=.*/BENCH_NETWORK=$sanitized_bench_name/" "$output_env_file"

  if [ -n "$custom_image_details" ]; then
    IFS=':' read -r custom_image custom_tag <<< "$custom_image_details"

    if [ -n "$custom_image" ] && [ -n "$custom_tag" ]; then
      sed -i "s/^CUSTOM_IMAGE=.*/CUSTOM_IMAGE=$custom_image/" "$output_env_file"
      sed -i "s/^CUSTOM_TAG=.*/CUSTOM_TAG=$custom_tag/" "$output_env_file"
    fi
  fi

  echo "Environment file template copied to: $output_env_file"

  read -p "Press enter to continue with editing the file... "
  nano "$output_env_file"

  if [ -s "$output_env_file" ]; then
    echo -e "\nEnvironment file was updated."
    echo "Final environment file contents:"
    cat $output_env_file
  else
    echo "Warning: Environment file is empty. Reverting to template."
    cp "$template_env_file" "$output_env_file"
  fi
}

main
#!/bin/bash

if [ $# -ne 2 ]; then
  echo "Error: This script requires two arguments: bench name and deployment directory"
  exit 1
fi

bench_name="$1"
deployment_dir="$2"

user_input() {
  echo "Available Docker Images:"
  docker images

  read -p "Enter the name of the base image you want to use: " base_image_name
  read -p "Enter the tag of the base image you want to use: " base_image_tag

  apps_json_path="$deployment_dir/$bench_name"_custom_apps.json

  if [ ! -f "$apps_json_path" ]; then
    echo "Error: apps.json file not found at $apps_json_path"
    exit 1
  fi

  APPS_JSON_BASE64=$(base64 -w 0 "$apps_json_path")

  read -p "Enter the name for the new image: " new_image_name
  read -p "Enter the tag for the new image: " new_image_tag

  echo -e "\nDocker Build Details: "
  echo "Base Image: $base_image_name:$base_image_tag"
  echo "New Image: $new_image_name:$new_image_tag"
  echo "apps.json Source: $apps_json_path"
}

main() {
  user_input

  while true; do

    read -p "Do you want to continue? [Y/n] " build_image
    build_image=$(echo "$build_image" | tr '[:upper:]' '[:lower:]')
    build_image=${build_image:-y}
    case "$build_image" in
      y|yes)
        log_file="$deployment_dir/${new_image_name//\//_}_${new_image_tag}_build.log"
        docker build \
          --build-arg=BASE_IMAGE="$base_image_name" \
          --build-arg=BASE_IMAGE_TAG="$base_image_tag" \
          --build-arg=APPS_JSON_BASE64="$APPS_JSON_BASE64" \
          --tag="$new_image_name:$new_image_tag" \
          --progress=plain \
          . 2>&1 | tee "$log_file"

        if [ ${PIPESTATUS[0]} -eq 0 ]; then
          echo -e "\nDocker image built successfully!"
          echo "Build log saved to: $log_file"

          # Save image details for potential future use
          image_details_file="$deployment_dir/${bench_name}_image_details.txt"
          echo "Base Image: $base_image_name:$base_image_tag" > "$image_details_file"
          echo "New Image: $new_image_name:$new_image_tag" >> "$image_details_file"
          echo "Build Log: $log_file" >> "$image_details_file"
        else
          echo "Docker image build failed. Check the log for details."
        fi
        break
        ;;
      n|no)
        user_input
        ;;
      *)
        echo "Invalid input"
        ;;
    esac
  done
}

main
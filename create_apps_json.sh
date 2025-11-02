#!/bin/bash

validate_git_url() {
  local url="$1"
      # Basic regex to check for valid Git repository URL
      if [[ "$url" =~ ^https?://([^/]+)/[^/]+/[^/]+(.git)?$ ]]; then
          return 0
      else
          return 1
      fi
}

if [ $# -ne 2 ]; then
  echo "Error: This script requires two arguments: bench name and deployment directory"
  exit 1
fi

bench_name="$1"
deployment_directory="$2"

echo "Creating apps.json for bench $bench_name"
echo "Deployment directory: $deployment_directory"

apps_json='['
first_entry=true

while true; do
  read -p "Add link to git repo (or press 'q' to finish): " repo_url

  if [[ "$repo_url" == "q" ]]; then
    break
  fi

  if ! validate_git_url "$repo_url"; then
    echo "Invalid Git repository URL. Please try again."
    continue
  fi

  read -p "Specify branch for $repo_url: " repo_branch

  if [ "$first_entry" = true ]; then
    apps_json+=$(printf '\n  {\n    "url": "%s",\n    "branch": "%s"\n  }' "$repo_url" "$repo_branch")
    first_entry=false
  else
    apps_json+=$(printf ',\n  {\n    "url": "%s",\n    "branch": "%s"\n  }' "$repo_url" "$repo_branch")
  fi
done

apps_json+=$'\n']

custom_apps_json="$deployment_directory/${bench_name}_custom_apps.json"

echo "$apps_json" > "$custom_apps_json"

echo "Custom apps JSON has been created at: $custom_apps_json"
echo "Contents:"
cat "$custom_apps_json"

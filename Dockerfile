ARG BASE_IMAGE=etms-base
ARG BASE_IMAGE_TAG=1.0.0

FROM ${BASE_IMAGE}:${BASE_IMAGE_TAG} AS builder

ARG APPS_JSON_BASE64

USER root

RUN if [ -n "${APPS_JSON_BASE64}" ]; then \
    mkdir /opt/frappe && echo "${APPS_JSON_BASE64}" | base64 -d > /opt/frappe/apps.json; \
  fi

USER frappe

WORKDIR /home/frappe/frappe-bench

# Custom app installation script
RUN set -e && \
    # Check if apps.json exists and is not empty
    if [ -s /opt/frappe/apps.json ]; then \
  	# Parse and install each app
        for row in $(jq -c '.[]' /opt/frappe/apps.json); do \
            app_url=$(echo "$row" | jq -r '.url') && \
            app_branch=$(echo "$row" | jq -r '.branch // "main"') && \
            \
            echo "Installing app: $app_name from $app_url (branch: $app_branch)" && \
            bench get-app --branch "$app_branch" "$app_url" || true; \
        done \
    fi

    # Clean up cache after app installation
RUN rm -rf /home/frappe/.cache

VOLUME [ \
  "/home/frappe/frappe-bench/sites", \
  "/home/frappe/frappe-bench/sites/assets", \
  "/home/frappe/frappe-bench/logs" \
]

CMD [ \
  "/home/frappe/frappe-bench/env/bin/gunicorn", \
  "--chdir=/home/frappe/frappe-bench/sites", \
  "--bind=0.0.0.0:8000", \
  "--threads=4", \
  "--workers=2", \
  "--worker-class=gthread", \
  "--worker-tmp-dir=/dev/shm", \
  "--timeout=120", \
  "--preload", \
  "frappe.app:application" \
]
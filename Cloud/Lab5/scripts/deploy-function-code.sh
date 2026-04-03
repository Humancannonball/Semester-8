#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <resource-group> <function-app-name>" >&2
  exit 1
fi

RESOURCE_GROUP_NAME=$1
FUNCTION_APP_NAME=$2
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

if ! command -v az >/dev/null 2>&1; then
  echo "Azure CLI is not installed. Install Azure CLI before running terraform apply." >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required to build the Azure Functions package." >&2
  exit 1
fi

if ! az account show >/dev/null 2>&1; then
  echo "Azure CLI is not authenticated. Run 'az login' first." >&2
  exit 1
fi

PACKAGE_PATH=$("${SCRIPT_DIR}/build-function-package.sh")

az functionapp deployment source config-zip \
  --resource-group "${RESOURCE_GROUP_NAME}" \
  --name "${FUNCTION_APP_NAME}" \
  --src "${PACKAGE_PATH}" \
  --output none

echo "Function code deployed to ${FUNCTION_APP_NAME}."

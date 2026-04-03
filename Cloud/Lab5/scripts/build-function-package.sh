#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
LAB_DIR=$(cd "${SCRIPT_DIR}/.." && pwd)
SRC_DIR="${LAB_DIR}/function_src"
BUILD_DIR="${LAB_DIR}/.build/functionapp"
SITE_PACKAGES_DIR="${BUILD_DIR}/.python_packages/lib/site-packages"
PACKAGE_PATH="${LAB_DIR}/function-app.zip"

rm -rf "${BUILD_DIR}"
mkdir -p "${SITE_PACKAGES_DIR}"
cp -R "${SRC_DIR}/." "${BUILD_DIR}/"

python3 -m pip install \
  --disable-pip-version-check \
  --quiet \
  --target "${SITE_PACKAGES_DIR}" \
  -r "${SRC_DIR}/requirements.txt"

rm -f "${PACKAGE_PATH}"
(cd "${BUILD_DIR}" && zip -qr "${PACKAGE_PATH}" .)

printf '%s\n' "${PACKAGE_PATH}"

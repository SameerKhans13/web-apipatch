#!/usr/bin/env bash
# Apipatch macOS & Linux Installer
# Usage: curl -fsSL https://apipatch.fix2ship.dev/install.sh | bash

set -euo pipefail

REPO="SameerKhans13/web-apipatch"
INSTALL_DIR="${HOME}/.apipatch/bin"
EXE_PATH="${INSTALL_DIR}/apipatch"
TMP_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

echo -e "\033[0;36mInstalling apipatch CLI for macOS / Linux...\033[0m"

# 1. Detect OS
OS="$(uname -s)"
case "${OS}" in
  Darwin*) TARGET_OS="darwin" ;;
  Linux*)  TARGET_OS="linux" ;;
  *)
    echo "Error: Unsupported operating system: ${OS}" >&2
    exit 1
    ;;
esac

# 2. Detect Architecture
ARCH="$(uname -m)"
case "${ARCH}" in
  x86_64*|amd64*) TARGET_ARCH="x64" ;;
  arm64*|aarch64*)
    if [ "${TARGET_OS}" = "darwin" ]; then
      TARGET_ARCH="arm64"
    else
      TARGET_ARCH="x64" # fallback x64 emulation
    fi
    ;;
  *)
    echo "Error: Unsupported architecture: ${ARCH}" >&2
    exit 1
    ;;
esac

ZIP_NAME="apipatch-${TARGET_OS}-${TARGET_ARCH}.zip"
DOWNLOAD_URL="https://github.com/${REPO}/releases/latest/download/${ZIP_NAME}"

# 3. Create install directory
mkdir -p "${INSTALL_DIR}"

# 4. Download and extract
echo "Downloading apipatch CLI (${TARGET_OS}-${TARGET_ARCH})..."
curl -fsSL "${DOWNLOAD_URL}" -o "${TMP_DIR}/${ZIP_NAME}"

extract_zip() {
  local zip_file="$1"
  local dest="$2"

  if command -v unzip >/dev/null 2>&1; then
    unzip -q -o "${zip_file}" -d "${dest}"
  elif command -v tar >/dev/null 2>&1 && tar -tf "${zip_file}" >/dev/null 2>&1; then
    tar -xf "${zip_file}" -C "${dest}"
  elif command -v python3 >/dev/null 2>&1; then
    python3 -c "import zipfile; zipfile.ZipFile('${zip_file}').extractall('${dest}')"
  elif command -v python >/dev/null 2>&1; then
    python -c "import zipfile; zipfile.ZipFile('${zip_file}').extractall('${dest}')"
  elif command -v busybox >/dev/null 2>&1; then
    busybox unzip -q "${zip_file}" -d "${dest}"
  else
    echo "Error: Neither 'unzip', 'tar', nor 'python3' is available to extract the package." >&2
    echo "Please install 'unzip' using: sudo apt update && sudo apt install -y unzip" >&2
    exit 1
  fi
}

extract_zip "${TMP_DIR}/${ZIP_NAME}" "${TMP_DIR}"
find "${TMP_DIR}" -type f -name "apipatch*" ! -name "*.zip" -exec mv -f {} "${EXE_PATH}" \;
chmod +x "${EXE_PATH}"

# 5. Shell configuration for PATH
update_shell_profile() {
  local profile="$1"
  local line='export PATH="$HOME/.apipatch/bin:$PATH"'
  if [ -f "${profile}" ]; then
    if ! grep -q "\.apipatch/bin" "${profile}"; then
      echo "" >> "${profile}"
      echo "${line}" >> "${profile}"
      echo "Added ~/.apipatch/bin to ${profile}"
    fi
  fi
}

update_shell_profile "${HOME}/.bashrc"
update_shell_profile "${HOME}/.zshrc"
update_shell_profile "${HOME}/.profile"

echo ""
echo -e "\033[0;32m✓ Successfully installed apipatch to: ${EXE_PATH}\033[0m"
echo -e "\033[0;36mRun 'apipatch --help' to get started.\033[0m"

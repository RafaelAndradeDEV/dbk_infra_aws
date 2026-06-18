#!/usr/bin/env bash
set -euo pipefail

# Install terraform-docs using pre-compiled binary
# Reference: https://terraform-docs.io/user-guide/installation/#pre-compiled-binary

VERSION="${TERRAFORM_DOCS_VERSION:-v0.20.0}"
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"

OS="$(uname | tr '[:upper:]' '[:lower:]')"
ARCH_RAW="$(uname -m)"
case "${ARCH_RAW}" in
  x86_64|amd64)
    ARCH="amd64"
    ;;
  arm64|aarch64)
    ARCH="arm64"
    ;;
  *)
    echo "Unsupported architecture: ${ARCH_RAW}" >&2
    exit 1
    ;;
esac

TARBALL="terraform-docs-${VERSION}-${OS}-${ARCH}.tar.gz"
URL="https://terraform-docs.io/dl/${VERSION}/terraform-docs-${VERSION}-${OS}-${ARCH}.tar.gz"

TMPDIR="$(mktemp -d)"
cleanup() { rm -rf "${TMPDIR}"; }
trap cleanup EXIT

echo "Downloading ${URL} ..."
curl -fsSL -o "${TMPDIR}/${TARBALL}" "${URL}"

echo "Extracting..."
tar -xzf "${TMPDIR}/${TARBALL}" -C "${TMPDIR}"

BIN_PATH="${TMPDIR}/terraform-docs"
chmod +x "${BIN_PATH}"

if [ ! -d "${INSTALL_DIR}" ]; then
  echo "Creating install directory: ${INSTALL_DIR}"
  mkdir -p "${INSTALL_DIR}"
fi

TARGET="${INSTALL_DIR}/terraform-docs"
if [ -w "${INSTALL_DIR}" ]; then
  mv "${BIN_PATH}" "${TARGET}"
else
  echo "Installing to ${TARGET} with sudo..."
  sudo mv "${BIN_PATH}" "${TARGET}"
fi

echo "terraform-docs installed to ${TARGET}"
"${TARGET}" --version || true

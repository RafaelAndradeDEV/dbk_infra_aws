#!/usr/bin/env bash
set -euo pipefail

# Install tfenv, Terraform (from .terraform-version), TFLint, and pre-commit
# Supports Debian/Ubuntu/macOS. For others, install tools manually.

detect_os() {
  unameOut="$(uname -s)"
  case "${unameOut}" in
      Linux*)     os=Linux;;
      Darwin*)    os=Darwin;;
      *)          os="UNKNOWN";;
  esac
  echo "$os"
}

ensure_tfenv_path() {
  if [ -d "$HOME/.tfenv/bin" ]; then
    case ":$PATH:" in
      *":$HOME/.tfenv/bin:"*) ;; # already in PATH
      *) export PATH="$HOME/.tfenv/bin:$PATH" ;;
    esac
  fi
}

install_tfenv() {
  if command -v tfenv >/dev/null 2>&1; then
    echo "tfenv already installed"
    ensure_tfenv_path
    return
  fi
  echo "Installing tfenv..."
  if [ -d "$HOME/.tfenv" ]; then
    echo "~/.tfenv already exists, skipping clone"
  else
    git clone --depth=1 https://github.com/tfutils/tfenv.git ~/.tfenv
  fi
  shell_name=$(basename "$SHELL")
  case "$shell_name" in
    bash) profile="$HOME/.bashrc";;
    zsh)  profile="$HOME/.zshrc";;
    *)    profile="$HOME/.profile";;
  esac
  if ! grep -q 'tfenv/bin' "$profile" 2>/dev/null; then
    echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> "$profile"
    echo "Added tfenv to PATH in $profile (restart shell to take effect)"
  fi
  # Ensure current shell can find tfenv immediately
  ensure_tfenv_path
}

install_terraform() {
  if ! command -v tfenv >/dev/null 2>&1; then
    echo "tfenv not found; cannot install terraform" >&2
    exit 1
  fi
  if [ ! -f ./.terraform-version ]; then
    echo ".terraform-version not found in project root" >&2
    exit 1
  fi
  echo "Installing Terraform via tfenv..."
  tfenv install
  tfenv use
  terraform -version
}

install_tflint() {
  if command -v tflint >/dev/null 2>&1; then
    echo "tflint already installed"
    return
  fi
  os=$(detect_os)
  echo "Installing tflint ($os)..."
  if [ "$os" = "Darwin" ]; then
    if command -v brew >/dev/null 2>&1; then
      brew install tflint
    else
      echo "Homebrew not found. Install tflint per docs: https://github.com/terraform-linters/tflint" >&2
      exit 1
    fi
  elif [ "$os" = "Linux" ]; then
    curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
  else
    echo "Unsupported OS for automatic TFLint install" >&2
    exit 1
  fi
}

install_precommit() {
  if command -v pre-commit >/dev/null 2>&1; then
    echo "pre-commit already installed"
    return
  fi
  echo "Installing pre-commit (pip)..."
  if command -v pip3 >/dev/null 2>&1; then
    pip3 install --user pre-commit
  else
    pip install --user pre-commit || true
  fi
}

enable_precommit() {
  if [ -f .pre-commit-config.yaml ]; then
    pre-commit install || true
  fi
}

main() {
  install_tfenv
  install_terraform
  install_tflint
  install_precommit
  enable_precommit
  echo "Setup complete. Restart your shell if PATH changes were applied."
}

main "$@"

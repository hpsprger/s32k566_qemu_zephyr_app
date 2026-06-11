#!/usr/bin/env bash
#
# setup-dev.sh - One-time development environment setup
#
# Installs required tools: cmake, ninja, Python west, ARM toolchain
#

set -euo pipefail

TOP_DIR="$(cd "$(dirname "$0")" && pwd)"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Determine OS
OS="$(uname -s)"

install_ubuntu_packages() {
    info "Installing system packages for Ubuntu/Debian..."
    sudo apt-get update -qq
    sudo apt-get install -y -qq \
        cmake \
        ninja-build \
        python3-pip \
        python3-venv \
        gperf \
        ccache \
        dfu-util \
        device-tree-compiler \
        wget \
        curl \
        file \
        git \
        make \
        gcc \
        g++ \
        libglib2.0-dev \
        libfdt-dev \
        libpixman-1-dev \
        zlib1g-dev \
        libncurses5-dev \
        libssl-dev \
        libgmp-dev \
        libmpfr-dev \
        libmpc-dev \
        flex \
        bison
}

install_zephyr_sdk() {
    ZSDK_VERSION="0.17.0"
    ZSDK_URL="https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${ZSDK_VERSION}/zephyr-sdk-${ZSDK_VERSION}_linux-x86_64.tar.xz"
    ZSDK_DIR="${TOP_DIR}/zephyr-sdk"

    if [ -d "$ZSDK_DIR" ]; then
        info "Zephyr SDK already installed at $ZSDK_DIR"
        return
    fi

    info "Downloading Zephyr SDK ${ZSDK_VERSION}..."
    wget -q --show-progress "$ZSDK_URL" -O /tmp/zephyr-sdk.tar.xz

    info "Extracting..."
    tar xf /tmp/zephyr-sdk.tar.xz -C "$TOP_DIR"
    mv "${TOP_DIR}/zephyr-sdk-${ZSDK_VERSION}" "$ZSDK_DIR"

    info "Running setup script..."
    cd "$ZSDK_DIR"
    ./setup.sh -t arm-zephyr-eabi -h
    cd "$TOP_DIR"

    rm -f /tmp/zephyr-sdk.tar.xz
    info "Zephyr SDK installed to $ZSDK_DIR"
}

install_python_deps() {
    info "Installing Python dependencies..."
    python3 -m venv "${TOP_DIR}/.venv" 2>/dev/null || python3 -m venv "${TOP_DIR}/.venv"
    source "${TOP_DIR}/.venv/bin/activate"
    pip install --quiet west pyelftools
    info "Python deps installed (virtual env at ${TOP_DIR}/.venv)"
}

# ---------- main ----------
info "Setting up development environment..."

case "$OS" in
    Linux)
        if grep -qi "ubuntu\|debian" /etc/os-release 2>/dev/null; then
            install_ubuntu_packages
        else
            warn "Unsupported Linux distro. Install packages manually."
        fi
        ;;
    Darwin)
        warn "macOS detected. Install Xcode Command Line Tools and brew packages manually."
        ;;
    *)
        error "Unsupported OS: $OS"
        exit 1
        ;;
esac

install_python_deps
install_zephyr_sdk

info "Development environment setup complete!"
echo ""
echo "Next steps:"
echo "  1. ./build.sh       # Build QEMU + Zephyr + App"
echo "  2. ./run.sh         # Run in QEMU"

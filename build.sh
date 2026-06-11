#!/usr/bin/env bash
#
# build.sh - Build the Zephyr app for QEMU s32k566 target
#
# Usage:
#   ./build.sh                    # Build everything (fetch submodules first)
#   ./build.sh app-only           # Build only the app (if submodules exist)
#   ./build.sh clean              # Clean build artifacts
#
set -euo pipefail

TOP_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="${TOP_DIR}/app"
BUILD_DIR="${TOP_DIR}/build"
QEMU_DIR="${TOP_DIR}/qemu"
ZEPHYR_DIR="${TOP_DIR}/zephyr"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# ---------- check prerequisites ----------
check_prereqs() {
    local missing=0
    for cmd in cmake python3 ninja wget; do
        if ! command -v "$cmd" &>/dev/null; then
            error "Missing prerequisite: $cmd"
            missing=1
        fi
    done

    # Check for required Python packages
    if ! python3 -c "import west" 2>/dev/null; then
        warn "Python 'west' not found. Installing..."
        pip3 install west --quiet || {
            error "Failed to install west. Install manually: pip3 install west"
            missing=1
        }
    fi

    if [ $missing -eq 1 ]; then
        error "Install missing prerequisites and retry."
        exit 1
    fi
}

# ---------- fetch submodules (shallow) ----------
fetch_submodules() {
    info "Fetching submodules (shallow clone)..."
    cd "$TOP_DIR"

    # Fetch QEMU (latest stable, shallow)
    if [ ! -d "$QEMU_DIR/.git" ]; then
        info "Cloning QEMU..."
        git clone --depth 1 --branch stable https://gitlab.com/qemu-project/qemu.git "$QEMU_DIR"
        cd "$QEMU_DIR"
        git checkout -b work_for_safety
        cd "$TOP_DIR"
    else
        info "QEMU already cloned"
    fi

    # Fetch Zephyr (latest main, shallow)
    if [ ! -d "$ZEPHYR_DIR/.git" ]; then
        info "Cloning Zephyr OS..."
        git clone --depth 1 --branch main https://github.com/zephyrproject-rtos/zephyr.git "$ZEPHYR_DIR"
        cd "$ZEPHYR_DIR"
        git checkout -b work_for_safety
        cd "$TOP_DIR"
    else
        info "Zephyr already cloned"
    fi
}

# ---------- build QEMU ----------
build_qemu() {
    info "Building QEMU for s32k target..."
    cd "$QEMU_DIR"

    if [ ! -f "configure" ]; then
        error "QEMU configure script not found. Is QEMU cloned properly?"
        exit 1
    fi

    mkdir -p build && cd build
    ../configure --target-list=arm-softmmu,aarch64-softmmu \
                 --enable-debug \
                 --disable-werror \
                 --prefix="$TOP_DIR/qemu-install" 2>&1 | tail -5

    make -j$(nproc) 2>&1 | tail -5
    make install 2>&1 | tail -3

    export PATH="$TOP_DIR/qemu-install/bin:$PATH"
    info "QEMU built and installed to $TOP_DIR/qemu-install"
    cd "$TOP_DIR"
}

# ---------- build Zephyr app ----------
build_app() {
    info "Building Zephyr app for s32k566_qemu target..."

    # Export Zephyr environment
    export ZEPHYR_BASE="$ZEPHYR_DIR"
    export PATH="$TOP_DIR/qemu-install/bin:$PATH"

    # Initialize west if needed
    if [ ! -f "$APP_DIR/.west" ]; then
        cd "$TOP_DIR"
        west init -l "$APP_DIR" 2>/dev/null || true
    fi

    # Build
    cd "$TOP_DIR"
    west build -b s32k566_qemu "$APP_DIR" -d "$BUILD_DIR" 2>&1 | tail -15

    if [ -f "$BUILD_DIR/zephyr/zephyr.elf" ]; then
        info "Build successful!"
        info "ELF: $BUILD_DIR/zephyr/zephyr.elf"
        info "HEX: $BUILD_DIR/zephyr/zephyr.hex"
    else
        error "Build failed - ELF not found"
        exit 1
    fi
}

# ---------- clean ----------
clean_all() {
    info "Cleaning build artifacts..."
    rm -rf "$BUILD_DIR"
    rm -rf "$QEMU_DIR/build"
    rm -rf "$TOP_DIR/qemu-install"
    info "Cleaned."
}

# ---------- main ----------
case "${1:-all}" in
    app-only)
        check_prereqs
        build_app
        ;;
    clean)
        clean_all
        ;;
    all)
        check_prereqs
        fetch_submodules
        build_qemu
        build_app
        ;;
    *)
        echo "Usage: $0 {all|app-only|clean}"
        exit 1
        ;;
esac

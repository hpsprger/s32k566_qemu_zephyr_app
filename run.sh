#!/usr/bin/env bash
#
# run.sh - Run the Zephyr app in QEMU s32k566 emulation
#
# Usage:
#   ./run.sh                # Run with serial output
#   ./run.sh -nographic     # Run without GUI (recommended for SSH)
#   ./run.sh -nographic -d in_asm  # With disassembly trace
#
set -euo pipefail

TOP_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="${TOP_DIR}/build"
QEMU_INSTALL="${TOP_DIR}/qemu-install"

QEMU_BIN="${QEMU_INSTALL}/bin/qemu-system-arm"
ZEPHYR_ELF="${BUILD_DIR}/zephyr/zephyr.elf"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

if [ ! -f "$QEMU_BIN" ]; then
    echo -e "${RED}[ERROR]${NC} QEMU not found at $QEMU_BIN"
    echo "Run ./build.sh first"
    exit 1
fi

if [ ! -f "$ZEPHYR_ELF" ]; then
    echo -e "${RED}[ERROR]${NC} Zephyr ELF not found at $ZEPHYR_ELF"
    echo "Run ./build.sh first"
    exit 1
fi

echo -e "${GREEN}[INFO]${NC} Starting QEMU S32K566 emulation..."
echo -e "${GREEN}[INFO]${NC} ELF: $ZEPHYR_ELF"
echo -e "${GREEN}[INFO]${NC} Press Ctrl-A then X to exit QEMU"
echo ""

# QEMU machine type for NXP S32K3xx series
# Run with serial stdio so the Hello World output appears in terminal
"$QEMU_BIN" \
    -M s32k3xx-evb \
    -cpu cortex-m7 \
    -m 512K \
    -nographic \
    -kernel "$ZEPHYR_ELF" \
    -serial mon:stdio \
    "$@"

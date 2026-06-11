# s32k566_qemu_zephyr_app

QEMU S32K566 emulation + Zephyr RTOS + Hello World UART App

## Repository Structure

```
s32k566_qemu_zephyr_app/
├── qemu/        ← QEMU (submodule, branch: work_for_safety)
├── zephyr/      ← Zephyr OS (submodule, branch: work_for_safety)
├── app/         ← Hello World App (branch: work_for_safety)
├── build.sh     ← Build QEMU + Zephyr + App
├── run.sh       ← Run the app in QEMU
├── setup-dev.sh ← One-time dev environment setup
└── README.md
```

## Quick Start

### 1. Fetch submodules

```bash
git submodule update --init --depth 1
```

Each submodule's working branch is `work_for_safety`.

### 2. Install prerequisites (first time only)

```bash
./setup-dev.sh
```

This installs: CMake, Ninja, Python `west`, ARM GCC toolchain (Zephyr SDK).

### 3. Build everything

```bash
./build.sh
```

This builds:
- QEMU (with ARM/S32K target support)
- Zephyr OS kernel
- Hello World app

### 4. Run in QEMU

```bash
./run.sh
```

Expected output:
```
S32K566 Hello World App started!
Hello World! - count: 1
Hello World! - count: 2
Hello World! - count: 3
...
```

Press `Ctrl+A` then `X` to exit QEMU.

## Build Only the App (after first full build)

```bash
./build.sh app-only
```

## Clean Build Artifacts

```bash
./build.sh clean
```

## Submodule Branches

Each submodule has a `work_for_safety` branch for tracking application-specific modifications:

- `qemu` → `work_for_safety`
- `zephyr` → `work_for_safety`
- `app` → `work_for_safety`

## Board Support

The app targets the `s32k566_qemu` board definition in Zephyr, which emulates the NXP S32K566 MCU (Cortex-M7, dual-core) on QEMU.

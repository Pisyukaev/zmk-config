#!/bin/bash
set -e

CONFIG_DIR="config"
OUTPUT_DIR="artifacts"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_header() { echo -e "\n${YELLOW}=== $1 ===${NC}"; }

check_dependencies() {
    local missing=0
    for cmd in west cmake ninja arm-none-eabi-gcc; do
        if ! command -v "$cmd" &>/dev/null; then
            print_error "$cmd not found"
            missing=1
        fi
    done
    if [ $missing -eq 1 ]; then
        echo ""
        echo "Install with:"
        echo "  sudo pacman -S cmake ninja arm-none-eabi-gcc arm-none-eabi-newlib"
        echo "  pipx install west && pipx inject west pyelftools"
        exit 1
    fi
}

init_workspace() {
    if [ ! -f ".west/config" ]; then
        print_header "Initializing west workspace"
        west init -l "$CONFIG_DIR"
    fi

    print_header "Updating west workspace"
    west update
}

build_target() {
    local board=$1
    local output_name=$2
    shift 2
    local extra_args=("$@")
    local build_dir="build_${output_name}"
    local project_root
    project_root="$(pwd)"

    print_header "Building ${output_name}"

    rm -rf "$build_dir"

    ZEPHYR_TOOLCHAIN_VARIANT=cross-compile \
    CROSS_COMPILE=/usr/bin/arm-none-eabi- \
    west build -b "$board" -s zmk/app -d "$build_dir" -- \
        -DBOARD_ROOT="$project_root" \
        -DZephyr_DIR="$project_root/zephyr/share/zephyr-package/cmake" \
        "${extra_args[@]}"

    if [ -f "$build_dir/zephyr/zmk.uf2" ]; then
        mkdir -p "$OUTPUT_DIR"
        cp "$build_dir/zephyr/zmk.uf2" "$OUTPUT_DIR/${output_name}.uf2"
        print_status "${output_name}.uf2"
    else
        print_error "Build failed for ${output_name}"
        return 1
    fi
}

main() {
    print_header "ZMK Local Build"
    check_dependencies
    init_workspace

    echo ""
    echo "Building targets..."

    # mriya_left
    build_target "mriya_left" "mriya_left" \
        -DCONFIG_ZMK_STUDIO=y -DCONFIG_ZMK_SPLIT=y \
        -DSNIPPET=studio-rpc-usb-uart

    # mriya_right
    build_target "mriya_right" "mriya_right" \
        -DCONFIG_ZMK_SPLIT=y

    # mriya_dongle
    build_target "nice_nano@2.0.0//zmk" "mriya_dongle" \
        "-DSHIELD=mriya_dongle dongle_display" \
        -DCONFIG_ZMK_STUDIO=y -DCONFIG_ZMK_SPLIT=y \
        -DSNIPPET=studio-rpc-usb-uart

    # settings_reset
    build_target "nice_nano@2.0.0//zmk" "settings_reset" \
        -DSHIELD=settings_reset

    print_header "Build complete!"
    ls -la "$OUTPUT_DIR/"*.uf2 2>/dev/null || echo "No .uf2 files found"
}

main "$@"

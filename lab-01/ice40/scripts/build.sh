#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CORE_NAME="local:adc-course:lab01-ice40:1.0.0"
BUILD_DIR="$PROJECT_DIR/build"

for tool in yosys nextpnr-ice40 icepack; do
    if ! command -v "$tool" &> /dev/null; then
        echo "Error: $tool not found. Install OSS CAD Suite first." >&2
        exit 1
    fi
done

source "$SCRIPT_DIR/setup.sh"

if [ -d "$BUILD_DIR" ]; then
    echo "Cleaning previous build ..."
    rm -rf "$BUILD_DIR"
fi

echo "Building $CORE_NAME ..."
cd "$PROJECT_DIR"
fusesoc run --target=synth "$CORE_NAME"

BITSTREAM="$BUILD_DIR/local_adc-course_lab01-ice40_1.0.0/synth-icestorm/local_adc-course_lab01-ice40_1.0.0.bin"
if [ -f "$BITSTREAM" ]; then
    echo "Build succeeded: $BITSTREAM"
else
    echo "Error: bitstream not found after build." >&2
    exit 1
fi

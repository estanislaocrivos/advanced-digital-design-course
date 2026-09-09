#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BITSTREAM="$PROJECT_DIR/build/local_adc-course_lab01-ice40_1.0.0/synth-icestorm/local_adc-course_lab01-ice40_1.0.0.bin"

if ! command -v iceprog &> /dev/null; then
    echo "Error: iceprog not found. Install OSS CAD Suite first." >&2
    exit 1
fi

if [ ! -f "$BITSTREAM" ]; then
    echo "Error: bitstream not found at $BITSTREAM" >&2
    echo "Run ./scripts/build.sh first." >&2
    exit 1
fi

echo "Programming FPGA with $BITSTREAM ..."
iceprog "$BITSTREAM"
echo "Done."

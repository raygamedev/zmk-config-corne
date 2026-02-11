#!/bin/bash
# Flash script for Corne keyboard with nice!nano controllers
# Usage: ./flash.sh [left|right]

set -e

SIDE="${1:-}"
ZMK_DIR="$HOME/zmk/zmk"
FIRMWARE_LEFT="$ZMK_DIR/app/build/left/zephyr/zmk.uf2"
FIRMWARE_RIGHT="$ZMK_DIR/app/build/right/zephyr/zmk.uf2"
MOUNT_POINT="/mnt/nicenano"

# Validate argument
if [[ "$SIDE" != "left" && "$SIDE" != "right" ]]; then
    echo "Usage: $0 [left|right]"
    echo "  left  - Flash left half firmware"
    echo "  right - Flash right half firmware"
    exit 1
fi

# Select firmware based on side
if [[ "$SIDE" == "left" ]]; then
    FIRMWARE="$FIRMWARE_LEFT"
else
    FIRMWARE="$FIRMWARE_RIGHT"
fi

# Check firmware exists
if [[ ! -f "$FIRMWARE" ]]; then
    echo "Error: Firmware not found at $FIRMWARE"
    echo "Run the build first."
    exit 1
fi

echo "Waiting for nice!nano ($SIDE) to enter bootloader mode..."
echo "Double-tap the reset button on the $SIDE half."
echo "Press Ctrl+C to cancel."
echo ""

# Monitor for nice!nano bootloader device
while true; do
    if mountpoint -q "$MOUNT_POINT"; then
        echo "Detected nice!nano at $MOUNT_POINT"
        sleep 1

        echo "Flashing $SIDE firmware..."
        cp "$FIRMWARE" "$MOUNT_POINT/"
        sync

        echo "Done! Firmware flashed to $SIDE half."
        echo ""
        echo "Waiting for another device... (Ctrl+C to exit)"

        # Wait for device to disconnect
        while mountpoint -q "$MOUNT_POINT"; do
            sleep 0.5
        done
        echo ""
    fi
    sleep 0.5
done

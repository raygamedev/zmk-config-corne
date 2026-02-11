# ZMK Build Instructions for Claude Code

This is a ZMK firmware configuration for a Corne split keyboard with nice!nano v2 controllers.

## Build Sequence

When asked to "build", "run the build sequence", or similar, execute both commands below to build firmware for both keyboard halves.

### Prerequisites
- Podman must be installed
- The `zmk-dev` container image must exist (built from `$HOME/zmk/zmk/.devcontainer/Dockerfile`)
- West workspace must be initialized (run `west init -l app/ && west update` inside container if not done)

### Build Commands

Run these two commands to build both halves:

```bash
# Build LEFT half
podman run -it --rm --security-opt label=disable \
  --workdir /workspaces/zmk \
  -v $HOME/zmk/zmk:/workspaces/zmk \
  -v $HOME/zmk/zmk-config-corne:/workspaces/zmk-config \
  zmk-dev /bin/bash -c "cd app && west build -p -d build/left -b nice_nano -- -DSHIELD=corne_left -DZMK_CONFIG=/workspaces/zmk-config/config"

# Build RIGHT half
podman run -it --rm --security-opt label=disable \
  --workdir /workspaces/zmk \
  -v $HOME/zmk/zmk:/workspaces/zmk \
  -v $HOME/zmk/zmk-config-corne:/workspaces/zmk-config \
  zmk-dev /bin/bash -c "cd app && west build -p -d build/right -b nice_nano -- -DSHIELD=corne_right -DZMK_CONFIG=/workspaces/zmk-config/config"
```

### Output Files

After successful build:
- Left half firmware: `$HOME/zmk/zmk/app/build/left/zephyr/zmk.uf2`
- Right half firmware: `$HOME/zmk/zmk/app/build/right/zephyr/zmk.uf2`

### Flashing

Use the flash script to automatically detect and flash when nice!nano enters bootloader mode:

```bash
# Flash left half (run, then double-tap reset on left nice!nano)
$HOME/zmk/zmk-config-corne/flash.sh left

# Flash right half (run, then double-tap reset on right nice!nano)
$HOME/zmk/zmk-config-corne/flash.sh right
```

The script will wait until it detects the device, flash automatically, and continue listening for more devices (Ctrl+C to exit).

## Notes

- Board name is `nice_nano` (not `nice_nano_v2`) - Zephyr 4.1 uses revision system, v2.0.0 is default
- The `-p` flag performs a pristine build (clean rebuild)
- Config files are in `$HOME/zmk/zmk-config-corne/config/` (corne.keymap, corne.conf)

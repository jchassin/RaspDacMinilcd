#!/bin/bash
set -euo pipefail

start_time="$(date +"%T")"
install_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
log_file="${install_dir}/install_log.txt"

CONFIG_FILE="/boot/firmware/config.txt"
OVERLAY_NAME="raspdac-mini-ili9341"
OVERLAY_DTS="${install_dir}/${OVERLAY_NAME}-overlay.dts"
OVERLAY_DTBO="${install_dir}/${OVERLAY_NAME}.dtbo"
OVERLAY_DEST="/boot/firmware/overlays/${OVERLAY_NAME}.dtbo"

echo "* Installing : RaspDAC Mini LCD configuration"
: > "$log_file"

# --------------------------------------------------------------------
# Must run as root
# --------------------------------------------------------------------
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this installer with sudo:"
    echo "  sudo $0"
    exit 1
fi

# User who invoked sudo.
TARGET_USER="${SUDO_USER:-}"

if [ -z "$TARGET_USER" ] || [ "$TARGET_USER" = "root" ]; then
    echo "Unable to determine the desktop user."
    echo "Run this script with sudo from the user's session."
    exit 1
fi

TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"

if [ -z "$TARGET_HOME" ] || [ ! -d "$TARGET_HOME" ]; then
    echo "Unable to determine home directory for user: $TARGET_USER"
    exit 1
fi

echo "Desktop user : $TARGET_USER"
echo "Home         : $TARGET_HOME"
echo "Install dir  : $install_dir"

# --------------------------------------------------------------------
# Dependencies
# --------------------------------------------------------------------
echo "* Installing dependencies"

apt-get update
apt-get install -y \
    device-tree-compiler \
    wlr-randr

# --------------------------------------------------------------------
# Compile and install Device Tree overlay
# --------------------------------------------------------------------
echo "* Installing ILI9341 DRM overlay"

if [ ! -f "$OVERLAY_DTS" ]; then
    echo "Missing Device Tree source:"
    echo "  $OVERLAY_DTS"
    exit 1
fi

dtc -@ -I dts -O dtb \
    -o "$OVERLAY_DTBO" \
    "$OVERLAY_DTS"

install -m 0644 "$OVERLAY_DTBO" "$OVERLAY_DEST"

# --------------------------------------------------------------------
# Raspberry Pi boot configuration
# --------------------------------------------------------------------
echo "* Configuring Raspberry Pi boot"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Missing Raspberry Pi configuration file:"
    echo "  $CONFIG_FILE"
    exit 1
fi

add_config_line()
{
    local line="$1"

    if ! grep -Fxq "$line" "$CONFIG_FILE"; then
        echo "$line" >> "$CONFIG_FILE"
        echo "Added to config.txt: $line"
    fi
}

add_config_line "dtparam=spi=on"
add_config_line "dtoverlay=vc4-kms-v3d"
add_config_line "max_framebuffers=2"
add_config_line "dtoverlay=raspdac-mini-ili9341"

# --------------------------------------------------------------------
# labwc configuration
# --------------------------------------------------------------------
echo "* Configuring labwc"

LABWC_DIR="${TARGET_HOME}/.config/labwc"
DISPLAY_SCRIPT="${LABWC_DIR}/raspdac-display.sh"
AUTOSTART="${LABWC_DIR}/autostart"

install -d -m 0755 -o "$TARGET_USER" -g "$TARGET_USER" "$LABWC_DIR"

cat > "$DISPLAY_SCRIPT" <<'EOF'
#!/bin/sh

# Wait until labwc/wlroots has created its outputs.
sleep 1

wlr-randr \
    --output HDMI-A-1 --off \
    --output SPI-1 --on \
    --pos 0,0
EOF

chown "$TARGET_USER:$TARGET_USER" "$DISPLAY_SCRIPT"
chmod 0755 "$DISPLAY_SCRIPT"

# Preserve existing labwc autostart.
touch "$AUTOSTART"
chown "$TARGET_USER:$TARGET_USER" "$AUTOSTART"

AUTOSTART_LINE="${DISPLAY_SCRIPT} &"

if ! grep -Fxq "$AUTOSTART_LINE" "$AUTOSTART"; then
    printf '\n%s\n' "$AUTOSTART_LINE" >> "$AUTOSTART"
fi

# --------------------------------------------------------------------
# Allow reinstall from web interface
# --------------------------------------------------------------------
echo "* Configuring reinstall command"

if ! getent group audiophonics >/dev/null; then
    groupadd audiophonics
fi

usermod -aG audiophonics "$TARGET_USER"

cat > /usr/local/bin/aplcdi <<EOF
#!/bin/sh
cd '${install_dir}'
exec /bin/bash '${install_dir}/install.sh'
EOF

chmod 0755 /usr/local/bin/aplcdi
chown root:root /usr/local/bin/aplcdi

cat > /etc/sudoers.d/audiophonics-raspdac-lcd <<'EOF'
%audiophonics ALL=(root) NOPASSWD: /usr/local/bin/aplcdi
EOF

chmod 0440 /etc/sudoers.d/audiophonics-raspdac-lcd

# Validate sudoers before finishing.
visudo -cf /etc/sudoers.d/audiophonics-raspdac-lcd

# --------------------------------------------------------------------
# Finish
# --------------------------------------------------------------------
echo ""
echo "* End of installation : RaspDAC Mini LCD Display"
echo "* Reboot required"
echo ""
echo "Started at $start_time, finished at $(date +"%T")" >> "$log_file"

exit 0


#!/bin/bash
set -euo pipefail

notify() {
    notify-send -a "iCloud Mount" "$1" "$2"
}

MOUNT_POINT="/home/barrettjflowers/iCloud/Vault"
ICLOUD_REMOTE="icloud:Obsidian/barrettjflowers"

if mountpoint -q "$MOUNT_POINT" 2>/dev/null; then
    notify "iCloud Mount" "Already mounted."
    exit 0
fi

mkdir -p "$MOUNT_POINT"

rclone mount "$ICLOUD_REMOTE" "$MOUNT_POINT" --vfs-cache-mode writes --daemon --allow-non-empty 2>&1 || {
    notify "iCloud Error" "Failed to mount iCloud."
    exit 1
}

notify "iCloud Mount" "iCloud mounted successfully."

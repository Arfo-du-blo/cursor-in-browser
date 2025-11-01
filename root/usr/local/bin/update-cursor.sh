#!/bin/bash

set -euo pipefail

API_URL="https://cursor.com/api/download?platform=linux-x64&releaseTrack=stable"
CURSOR_APP_IMAGE="/Cursor.AppImage"

# Check dependencies
for cmd in curl python3; do
  command -v "$cmd" >/dev/null 2>&1 || {
    yad --error --text="Missing required command: $cmd" --width=400 --button=gtk-ok 2>/dev/null || echo "Missing required command: $cmd" >&2
    exit 1
  }
done

# Show progress dialog
yad --info --no-buttons --text="Checking for Cursor updates..." --fixed --width=300 --height=100 --text-align=center --undecorated 2>/dev/null &
DIALOG_PID_1=$!

# Fetch latest release info
json=$(curl -fsSL "$API_URL")
download_url=$(echo "$json" | python3 -c "import json, sys; data = json.load(sys.stdin); print(data['downloadUrl'])")
version=$(echo "$json" | python3 -c "import json, sys; data = json.load(sys.stdin); print(data.get('version', 'latest'))")

if [[ -z "$download_url" || "$download_url" == "null" ]]; then
  kill "$DIALOG_PID_1" 2>/dev/null || true
  wait "$DIALOG_PID_1" 2>/dev/null || true
  yad --error --text="Failed to retrieve download URL from API" --fixed --width=300 --height=100 --text-align=center --undecorated --button=gtk-ok 2>/dev/null || echo "Failed to retrieve download URL" >&2
  exit 1
fi

# Close the checking dialog
kill "$DIALOG_PID_1" 2>/dev/null || true
wait "$DIALOG_PID_1" 2>/dev/null || true

yad --info --text="Latest Cursor version: $version\nDownloading..." --fixed --width=300 --height=100 --text-align=center --undecorated --no-buttons 2>/dev/null &
DIALOG_PID_2=$!

# Download to a temp file first
tmpfile=/tmp/Cursor-$version.AppImage
curl -L --progress-bar -o "$tmpfile" "$download_url" || {
  rm -f "$tmpfile"
  kill "$DIALOG_PID_2" 2>/dev/null || true
  wait "$DIALOG_PID_2" 2>/dev/null || true
  yad --error --text="Failed to download Cursor" --fixed --width=300 --height=100 --text-align=center --undecorated --button=gtk-ok 2>/dev/null || echo "Failed to download" >&2
  exit 1
}

# Close the downloading dialog
kill "$DIALOG_PID_2" 2>/dev/null || true
wait "$DIALOG_PID_2" 2>/dev/null || true

# Replace old AppImage (requires root permissions)
sudo mv "$tmpfile" "$CURSOR_APP_IMAGE"
sudo chmod +x "$CURSOR_APP_IMAGE"

yad --info --text="✓ Cursor updated to version $version" --fixed --width=300 --height=100 --text-align=center --undecorated --button=gtk-ok 2>/dev/null

exit 0


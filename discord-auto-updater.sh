#!/usr/bin/env bash
set -euo pipefail

LOG_TAG="[discord-auto-update]"

echo "$LOG_TAG Starting check..."

LATEST_VERSION=$(curl -fsSI "https://discord.com/api/download?platform=linux&format=deb" \
  | grep -i '^location:' \
  | sed -E 's/.*linux\/([0-9.]+)\/.*/\1/' \
  | tr -d '\r')

echo "$LOG_TAG Latest version: $LATEST_VERSION"

INSTALLED_VERSION=$(dpkg-query -W -f='${Version}' discord 2>/dev/null || true)

echo "$LOG_TAG Installed version: ${INSTALLED_VERSION:-none}"

if [[ -z "${INSTALLED_VERSION}" ]] || dpkg --compare-versions "$LATEST_VERSION" gt "$INSTALLED_VERSION"; then
  echo "$LOG_TAG Update required. Installing..."

  TMP_DEB="/tmp/discord-latest.deb"

  wget -q -O "$TMP_DEB" "https://discord.com/api/download?platform=linux&format=deb"

  sudo dpkg -i "$TMP_DEB"

  echo "$LOG_TAG Update finished."
else
  echo "$LOG_TAG Already up to date."
fi

echo "$LOG_TAG Disabling one-shot service..."
systemctl disable discord-auto-update-once.service || true

echo "$LOG_TAG Done."

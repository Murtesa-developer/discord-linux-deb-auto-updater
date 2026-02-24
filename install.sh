#!/usr/bin/env bash
set -euo pipefail

echo "[installer] Installing Discord auto-update one-shot service..."

SCRIPT_PATH="/usr/local/bin/discord-auto-update.sh"
SERVICE_PATH="/etc/systemd/system/discord-auto-update-once.service"

cat > "$SCRIPT_PATH" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

LOG_TAG="[discord-auto-update]"

echo "$LOG_TAG Starting check..."

# --- get latest version from redirect ---
LATEST_VERSION=$(curl -fsSI "https://discord.com/api/download?platform=linux&format=deb" \
  | grep -i '^location:' \
  | sed -E 's/.*linux\/([0-9.]+)\/.*/\1/' \
  | tr -d '\r')

echo "$LOG_TAG Latest version: $LATEST_VERSION"

# --- get installed version ---
INSTALLED_VERSION=$(dpkg-query -W -f='${Version}' discord 2>/dev/null || true)

echo "$LOG_TAG Installed version: ${INSTALLED_VERSION:-none}"

# --- compare versions ---
if [[ -z "${INSTALLED_VERSION}" ]] || dpkg --compare-versions "$LATEST_VERSION" gt "$INSTALLED_VERSION"; then
  echo "$LOG_TAG Update required. Installing..."

  TMP_DEB="/tmp/discord-latest.deb"

  wget -q -O "$TMP_DEB" "https://discord.com/api/download?platform=linux&format=deb"

  apt-get update -y
  apt-get install -y "$TMP_DEB"

  echo "$LOG_TAG Update finished."
else
  echo "$LOG_TAG Already up to date."
fi

# --- disable service after first run ---
echo "$LOG_TAG Disabling one-shot service..."
systemctl disable discord-auto-update-once.service || true

echo "$LOG_TAG Done."
EOF

chmod +x "$SCRIPT_PATH"
echo "[installer] Updater script installed."

cat > "$SERVICE_PATH" <<'EOF'
[Unit]
Description=Discord Auto Update Once at Boot
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
User=root
Group=root
ExecStart=/usr/local/bin/discord-auto-update.sh
RemainAfterExit=no
TimeoutStartSec=10min

[Install]
WantedBy=multi-user.target
EOF

echo "[installer] Service file created."

systemctl daemon-reload
systemctl enable discord-auto-update-once.service

echo "[installer] Service enabled."

echo
echo "Installation complete."
echo "It will run once on next boot."
echo
echo "Useful commands:"
echo "  sudo systemctl start discord-auto-update-once.service"
echo "  journalctl -u discord-auto-update-once.service -b"

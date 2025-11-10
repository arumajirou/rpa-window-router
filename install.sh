#!/usr/bin/env bash
set -euo pipefail
PREFIX="$HOME"
echo "[install] -> $PREFIX"

# スクリプト配置
install -Dm755 bin/site_window_router.sh "$PREFIX/bin/site_window_router.sh"
install -Dm755 bin/swrctl              "$PREFIX/bin/swrctl"

# 設定
mkdir -p "$PREFIX/.config"
if [[ ! -f "$PREFIX/.config/site_window_router.conf" ]]; then
  install -Dm644 config/site_window_router.conf.example "$PREFIX/.config/site_window_router.conf"
else
  echo "[install] keep existing ~/.config/site_window_router.conf"
fi

# 自動起動（ヒアドキュメントではなく printf で出力）
mkdir -p "$PREFIX/.config/autostart"
printf '%s\n' \
  '[Desktop Entry]' \
  'Type=Application' \
  'Name=Site Window Router' \
  "Exec=$PREFIX/bin/site_window_router.sh" \
  'X-GNOME-Autostart-enabled=true' \
  > "$PREFIX/.config/autostart/site-window-router.desktop"

echo "[install] done"

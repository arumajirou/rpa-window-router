\
    #!/usr/bin/env bash
    set -euo pipefail
    echo "[uninstall] removing files (config is kept)"
    rm -f "$HOME/bin/site_window_router.sh" "$HOME/bin/swrctl"
    rm -f "$HOME/.config/autostart/site-window-router.desktop"
    echo "[uninstall] keep ~/.config/site_window_router.conf"

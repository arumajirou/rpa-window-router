\
    # rpa-window-router

    特定サイト（YouTube / ニコニコ / Zenime / Reddit / Bilibili）を開いた Brave/Chrome/Chromium/Edge のウィンドウを右端モニタへ自動移動。任意で5分後に自動最小化。

    - 依存: `wmctrl`, `xdotool`, `x11-utils`
    - Wayland ではブラウザを XWayland で起動（Chromium系は `--ozone-platform=x11`）

    ## インストール
    ```bash
    ./install.sh
    ```

    ## 使い方
    ```bash
    swrctl status
    swrctl move on
    swrctl minimize on
    swrctl delay 600
    ```

    ## 対象判定
    - WM_CLASS: `(brave-browser|brave-x11|google-chrome|chromium|microsoft-edge|microsoft-edge-beta|microsoft-edge-dev|msedge)`
    - タイトル: `youtube|youtu.be|nicovideo|niconico|ニコニコ|zenime|zenime.site|reddit|old.reddit|bilibili|bilibili.com|哔哩哔哩`
# rpa-window-router

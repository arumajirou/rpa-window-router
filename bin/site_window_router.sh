\
    #!/usr/bin/env bash
    set -u
    shopt -s extglob

    # 監視対象（WM_CLASS）
    CLASSES='(brave-browser|brave-x11|google-chrome|chromium|microsoft-edge|microsoft-edge-beta|microsoft-edge-dev|msedge)'

    # 対象サイト（タブタイトルに含まれる語）
    # YouTube / ニコニコ / Zenime / Reddit / Bilibili（中国語表記も）
    SITES='(youtube|youtu\.be|YouTube|nicovideo|niconico|ニコニコ|zenime|zenime\.site|reddit|old\.reddit|bilibili|bilibili\.com|哔哩哔哩)'

    # 設定ファイル（自動リロード）
    CONF="$HOME/.config/site_window_router.conf"
    MOVE_ENABLED=1            # 右端へ移動：1=有効, 0=無効
    MINIMIZE_ENABLED=0        # 5分後に最小化：1=有効, 0=無効
    MINIMIZE_DELAY=300        # 秒

    declare -A SEEN_TS        # WID → 初回検出epoch
    interval=0.5

    load_conf() { [[ -f "$CONF" ]] && source "$CONF" || true; }
    get_conf_mtime(){ stat -c %Y "$CONF" 2>/dev/null || echo 0; }

    rightmost() {
      # 右端モニタの原点 (RX RY)
      xrandr --listmonitors \
      | awk '/\+/{split($3,a,"+"); printf "%d %d\n", a[length(a)-1], a[length(a)]}' \
      | sort -n | tail -1
    }

    is_minimized() {
      local wid="$1"
      xprop -id "$wid" _NET_WM_STATE 2>/dev/null | grep -q '_NET_WM_STATE_HIDDEN'
    }

    move_one() {
      local wid="$1" rx="$2" ry="$3"
      wmctrl -i -r "$wid" -b remove,maximized_vert,maximized_horz
      wmctrl -i -r "$wid" -e "0,${rx},${ry},-1,-1" || xdotool windowmove "$wid" "$rx" "$ry"
    }

    minimize_one() {
      local wid="$1"
      wmctrl -i -r "$wid" -b add,hidden || xdotool windowminimize "$wid"
    }

    load_conf; CONF_MTIME=$(get_conf_mtime)

    while :; do
      # 設定のホットリロード
      NEW_MTIME=$(get_conf_mtime)
      if [[ "$NEW_MTIME" != "$CONF_MTIME" ]]; then
        load_conf
        CONF_MTIME="$NEW_MTIME"
      fi

      # 右端座標
      read -r RX RY < <(rightmost)
      if [[ -z "${RX:-}" || -z "${RY:-}" ]]; then
        sleep "$interval"; continue
      fi

      now=$(date +%s)
      declare -A LIVE=()

      # wmctrl: id desk pid x y w h class host title...
      while IFS=$'\t' read -r WID X Y CLS TITLE; do
        [[ -z "$WID" ]] && continue
        LIVE["$WID"]=1

        # 右端移動（ON時のみ）
        if [[ "$MOVE_ENABLED" == "1" ]]; then
          if ! (( X>=RX && ( (Y-RY<80 && RY-Y<80) ) )); then
            move_one "$WID" "$RX" "$RY"
          fi
        fi

        # 5分後最小化（ON時のみ）
        if [[ "$MINIMIZE_ENABLED" == "1" ]]; then
          if ! is_minimized "$WID"; then
            if [[ -z "${SEEN_TS[$WID]:-}" ]]; then
              SEEN_TS[$WID]=$now
            else
              delta=$(( now - SEEN_TS[$WID] ))
              if (( delta >= MINIMIZE_DELAY )); then
                minimize_one "$WID"
                unset SEEN_TS[$WID]
              fi
            fi
          else
            unset SEEN_TS[$WID]
          fi
        fi

      done < <(
        wmctrl -lpGx \
        | awk -vOFS='\t' -v classes="$CLASSES" -v sites="$SITES" '
            BEGIN{IGNORECASE=1}
            $0 ~ classes && $0 ~ sites {
              print $1, $4, $5, $8, substr($0, index($0,$10))
            }'
      )

      # 終了したウィンドウのタイマー掃除
      for wid in "${!SEEN_TS[@]}"; do
        [[ -n "${LIVE[$wid]:-}" ]] || unset SEEN_TS[$wid]
      done

      sleep "$interval"
    done

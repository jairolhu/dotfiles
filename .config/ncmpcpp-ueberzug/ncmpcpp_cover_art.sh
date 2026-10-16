#!/bin/sh
# ncmpcpp cover art script (ueberzugpp version, "compartment" layout)
# Called by ncmpcpp on every song change, and once at startup by the wrapper.
# Errors are logged to /tmp/ncmpcpp-cover.log

# ===== SETTINGS ==============================================================
music_library="$HOME/Music"

# The cover "compartment": the space reserved for the cover by a blank column
# (the one written "(NN)[]{}") in ncmpcpp's song_columns_list_format.
# With auto_compartment the script reads that format from your ncmpcpp config
# and uses exactly the free space. If the blank column is the LAST one, the
# compartment is everything to the right of your other columns.
auto_compartment="true"
ncmpcpp_config=""           # empty = auto (~/.config/ncmpcpp/config or ~/.ncmpcpp/config)

# Manual fallback, only used if auto detection fails:
compartment_side="right"    # right (blank column last) or left (blank column first)
compartment_percent=25      # width of the compartment, % of the terminal width
inset_cols=1                # empty columns kept on each side of the cover
cover_halign="center"       # left, center or right inside the compartment
cover_valign="center"       # top, center or bottom inside the compartment

padding_top=4               # rows above the cover (header + column titles)
padding_bottom=2            # rows below the cover (progress bar + status line)

debug=0                     # set to 1 to log resize events to /tmp/ncmpcpp-cover.log

# Leave empty to auto-detect. Only set both if the cover has the wrong size
# (width and height of one character cell, in pixels).
font_width=
font_height=
# =============================================================================

log="/tmp/ncmpcpp-cover.log"
tmp_cover="/tmp/mpd_cover_$$.jpg"

main() {
    if [ -z "$FIFO_UEBERZUG" ] || [ ! -p "$FIFO_UEBERZUG" ]; then
        echo "$(date): FIFO_UEBERZUG missing. Start ncmpcpp with the ncmpcpp-cover wrapper." >> "$log"
        exit 1
    fi
    kill_previous_instances >/dev/null 2>&1
    read_column_format
    find_cover_image 2>>"$log"
    display_cover_image 2>>"$log"
    detect_window_resizes >/dev/null 2>&1
}

# ==== Finding the cover ======================================================

kill_previous_instances() {
    command -v pidof >/dev/null 2>&1 || return
    script_name=$(basename "$0")
    for pid in $(pidof -x "$script_name"); do
        [ "$pid" != "$$" ] && kill -15 "$pid"
    done
}

find_image_in() {
    images="$(find "$1" -maxdepth 1 -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) 2>/dev/null)"
    [ -z "$images" ] && return 1
    cover_path="$(printf '%s\n' "$images" | grep -iE '/(cover|folder|front|album|artwork)[^/]*$' | head -n1)"
    [ -n "$cover_path" ] || cover_path="$(printf '%s\n' "$images" | head -n1)"
    [ -n "$cover_path" ]
}

find_cover_image() {
    cover_path=""
    rm -f /tmp/mpd_cover_*.jpg

    file="$(mpc --format %file% current)"
    [ -z "$file" ] && return
    full_path="$music_library/$file"

    # 1. Embedded art, asked directly from MPD (needs mpc >= 0.33, MPD >= 0.22)
    if mpc readpicture "$file" > "$tmp_cover" 2>/dev/null && [ -s "$tmp_cover" ]; then
        cover_path="$tmp_cover"
        return
    fi
    rm -f "$tmp_cover"

    # 2. Embedded art, extracted with ffmpeg
    if command -v ffmpeg >/dev/null 2>&1 && [ -f "$full_path" ]; then
        if ffmpeg -loglevel quiet -y -i "$full_path" -an -frames:v 1 "$tmp_cover" 2>/dev/null \
            && [ -s "$tmp_cover" ]; then
            cover_path="$tmp_cover"
            return
        fi
        rm -f "$tmp_cover"
    fi

    # 3. Image file in the album folder (or its parent, for CD1/CD2 layouts)
    case "$file" in
        */*) rel_dir="${file%/*}" ;;
        *)   rel_dir="" ;;
    esac
    if [ -n "$rel_dir" ]; then
        album_dir="$music_library/$rel_dir"
    else
        album_dir="$music_library"
    fi
    find_image_in "$album_dir" && return
    case "$rel_dir" in
        */*) find_image_in "$music_library/${rel_dir%/*}" && return ;;
    esac

    cover_path=""
}

# ==== Displaying the cover ===================================================

send_to_ueberzug() {
    # "<>" opens the FIFO read-write so this can never block ncmpcpp
    printf '%s\n' "$1" 1<>"$FIFO_UEBERZUG"
}

remove_cover_image() {
    send_to_ueberzug '{"action":"remove","identifier":"mpd_cover"}'
}

display_cover_image() {
    if [ -z "$cover_path" ] || [ ! -f "$cover_path" ]; then
        remove_cover_image
        return
    fi
    if ! compute_geometry; then
        remove_cover_image
        return
    fi
    esc_path="$(printf '%s' "$cover_path" | sed 's/\\/\\\\/g; s/"/\\"/g')"
    # Always remove first: the x11 backend can leave a stale window behind otherwise
    remove_cover_image
    send_to_ueberzug "{\"action\":\"add\",\"identifier\":\"mpd_cover\",\"path\":\"$esc_path\",\"x\":$ueber_left,\"y\":$ueber_top,\"width\":$ueber_width,\"height\":$ueber_height}"
}

on_resize() {
    [ "$debug" = "1" ] && echo "$(date +%T) resize" >> "$log"
    display_cover_image
}

detect_window_resizes() {
    {
        trap 'on_resize' WINCH
        while [ -p "$FIFO_UEBERZUG" ]; do sleep 0.2; done
    } &
}

# ==== Geometry ===============================================================

read_column_format() {
    cfg="$ncmpcpp_config"
    if [ -z "$cfg" ]; then
        for f in "$HOME/.config/ncmpcpp/config" "$HOME/.ncmpcpp/config"; do
            if [ -f "$f" ]; then
                cfg="$f"
                break
            fi
        done
    fi
    column_format=""
    [ -f "$cfg" ] || return 0
    column_format="$(grep -E '^[[:space:]]*song_columns_list_format[[:space:]]*=' "$cfg" \
        | tail -n1 | sed 's/^[^=]*=//')"
}

# Sets comp_left and compartment_cols (in terminal columns)
detect_compartment() {
    comp_left=""
    compartment_cols=""

    if [ "$auto_compartment" = "true" ] && [ -n "$column_format" ]; then
        # Walk the columns like ncmpcpp does: "(25)" = 25% of the width,
        # "(10f)" = 10 fixed columns. The blank column is the one with "{}".
        layout="$(printf '%s\n' "$column_format" | awk -v cols="$term_cols" '
            {
                s = $0; start = 0; found = 0; blank_w = 0; after = 0
                while (match(s, /\([0-9]+f?\)[^(]*/)) {
                    piece = substr(s, RSTART, RLENGTH)
                    s = substr(s, RSTART + RLENGTH)
                    n = substr(piece, 2)
                    sub(/\).*/, "", n)
                    fixed = (n ~ /f$/)
                    sub(/f$/, "", n)
                    w = fixed ? n + 0 : int(cols * n / 100)
                    if (found) after++
                    else if (index(piece, "{}") > 0) { found = 1; blank_w = w }
                    else start += w
                }
                if (found) {
                    if (after == 0) print start, cols - start
                    else print start, blank_w
                }
            }')"
        det_left="${layout% *}"
        det_width="${layout#* }"
        if [ "$det_left" -ge 0 ] 2>/dev/null && [ "$det_width" -ge 4 ] 2>/dev/null; then
            comp_left=$det_left
            compartment_cols=$det_width
        fi
    fi

    if [ -z "$comp_left" ]; then
        compartment_cols=$(( term_cols * compartment_percent / 100 ))
        if [ "$compartment_side" = "left" ]; then
            comp_left=0
        else
            comp_left=$(( term_cols - compartment_cols ))
        fi
    fi
}

compute_geometry() {
    unset LINES COLUMNS
    size="$(stty size 2>/dev/null </dev/tty)" || size=""
    if [ -n "$size" ]; then
        term_lines="${size% *}"
        term_cols="${size#* }"
    else
        term_lines="$(tput lines)"
        term_cols="$(tput cols)"
    fi

    fw="$font_width"
    fh="$font_height"
    if [ -z "$fw" ] || [ -z "$fh" ]; then
        guess_font_size
    fi

    detect_compartment

    # The free area inside the compartment
    box_w=$(( compartment_cols - 2 * inset_cols ))
    box_h=$(( term_lines - padding_top - padding_bottom ))
    [ "$box_w" -ge 4 ] && [ "$box_h" -ge 2 ] || return 1

    # Largest square that fits in the box
    # (cells are taller than wide, so a square is fewer rows than columns)
    sq_h=$(( box_w * fw / fh ))
    if [ "$sq_h" -le "$box_h" ]; then
        ueber_width=$box_w
        ueber_height=$sq_h
    else
        ueber_height=$box_h
        ueber_width=$(( box_h * fh / fw ))
    fi
    [ "$ueber_width" -ge 4 ] && [ "$ueber_height" -ge 2 ] || return 1

    # Horizontal position inside the compartment
    case "$cover_halign" in
        left)  ueber_left=$(( comp_left + inset_cols )) ;;
        right) ueber_left=$(( comp_left + compartment_cols - inset_cols - ueber_width )) ;;
        *)     ueber_left=$(( comp_left + (compartment_cols - ueber_width) / 2 )) ;;
    esac

    # Vertical position inside the compartment
    case "$cover_valign" in
        top)    ueber_top=$padding_top ;;
        bottom) ueber_top=$(( padding_top + box_h - ueber_height )) ;;
        *)      ueber_top=$(( padding_top + (box_h - ueber_height) / 2 )) ;;
    esac
}

guess_font_size() {
    # Fallback: a character cell is roughly twice as tall as wide
    fw=1
    fh=2
    py="$(command -v python3 || command -v python)" || return
    px="$("$py" - 2>/dev/null <<'END'
import fcntl, struct, termios
with open("/dev/tty") as t:
    r, c, x, y = struct.unpack("HHHH", fcntl.ioctl(t, termios.TIOCGWINSZ, struct.pack("HHHH", 0, 0, 0, 0)))
print(x, y)
END
)"
    pw="${px% *}"
    ph="${px#* }"
    if [ "${pw:-0}" -gt 0 ] && [ "${ph:-0}" -gt 0 ]; then
        guess_w=$(( pw / term_cols ))
        guess_h=$(( ph / term_lines ))
        if [ "$guess_w" -gt 0 ] && [ "$guess_h" -gt 0 ]; then
            fw=$guess_w
            fh=$guess_h
        fi
    fi
}

main

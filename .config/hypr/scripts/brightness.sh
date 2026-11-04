#!/usr/bin/env bash

STEP_LO=3    # perceived % per press at 0%
STEP_HI=12   # perceived % per press at 100% (step grows linearly between)
CURVE=2      # raw = max * (perceived/100)^CURVE; higher = finer low end
BOOST_STEP=10  # % per press above 100% backlight
BOOST_MAX=200
BOOST_DIR="$XDG_RUNTIME_DIR/hypr-boost"
BOOST_FILE="$BOOST_DIR/level"

get_percent() {
    awk -v raw="$(brightnessctl get)" -v max="$(brightnessctl max)" -v k="$CURVE" \
        'BEGIN { printf "%.0f", (raw/max)^(1/k) * 100 }'
}

# Step in perceived space, step = a + b*p so presses get bigger toward the top; down
# solves p' + step(p') = p so up/down retrace. Always move >= 1 raw unit, never below 1 (0 = panel off)
step_backlight() {
    local raw
    raw=$(awk -v raw="$(brightnessctl get)" -v max="$(brightnessctl max)" -v k="$CURVE" \
        -v dir="$1" -v a="$STEP_LO" -v hi="$STEP_HI" 'BEGIN {
        b = (hi - a) / 100
        p = (raw/max)^(1/k) * 100
        if (dir == "up") { d = 1; p += a + b*p } else { d = -1; p = (p - a) / (1 + b) }
        if (p > 100) p = 100; if (p < 0) p = 0
        n = int(max * (p/100)^k + 0.5)
        if (n == raw) n += d
        if (n > max) n = max; if (n < 1) n = 1
        print n
    }')
    brightnessctl -q set "$raw"
}

ID_FILE="/tmp/osd-notif-id"
osd_notify() {
    local old_id new_id
    old_id=$(cat "$ID_FILE" 2>/dev/null || echo 0)
    new_id=$(notify-send -r "$old_id" -p -t 1500 "$@")
    echo "$new_id" > "$ID_FILE"
}

# Past 100% backlight, screen shader lifts midtones then stretches contrast
# around 0.5; t = 0..1 across 100..200%
set_boost() {
    local level=$1 shader=""
    mkdir -p "$BOOST_DIR"
    echo "$level" > "$BOOST_FILE"
    if (( level > 100 )); then
        shader="$BOOST_DIR/boost-$level.glsl"
        cat > "$shader" <<GLSL
#version 300 es
precision highp float;
in vec2 v_texcoord;
out vec4 fragColor;
uniform sampler2D tex;
void main() {
    vec4 c = texture(tex, v_texcoord);
    float t = float($level - 100) / 100.0;
    vec3 rgb = pow(c.rgb, vec3(100.0 / float($level)));
    rgb = (rgb - 0.5) * (1.0 + 0.5 * t) + 0.5;
    fragColor = vec4(clamp(rgb, 0.0, 1.0), c.a);
}
GLSL
    fi
    hyprctl eval "hl.config({ decoration = { screen_shader = '$shader' } })" >/dev/null
}

pct=$(get_percent)
boost=$(cat "$BOOST_FILE" 2>/dev/null || echo 100)

case "$1" in
    up)
        if (( pct >= 100 )); then
            boost=$(( boost + BOOST_STEP > BOOST_MAX ? BOOST_MAX : boost + BOOST_STEP ))
            set_boost "$boost"
        else
            step_backlight up
        fi
        ;;
    down)
        if (( boost > 100 )); then
            boost=$(( boost - BOOST_STEP < 100 ? 100 : boost - BOOST_STEP ))
            set_boost "$boost"
        else
            step_backlight down
        fi
        ;;
esac

if (( boost > 100 )); then
    osd_notify "Brightness" "${boost}% (boost)"
else
    osd_notify "Brightness" "$(get_percent)%"
fi

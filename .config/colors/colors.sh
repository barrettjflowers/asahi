#!/bin/bash
# One source of truth — edit the 5 hex values below, then run ./colors.sh

BACKGROUND="1E1F1E"
TEXT="828782"
ACCENT="3F4843"
INACTIVE="303032"
URGENT="f53c3c"

DIR="$(cd "$(dirname "$0")" && pwd)"

BG_R=$((16#${BACKGROUND:0:2}))
BG_G=$((16#${BACKGROUND:2:2}))
BG_B=$((16#${BACKGROUND:4:2}))

cat > "$DIR/colors.css" << EOF
@define-color background rgba($BG_R, $BG_G, $BG_B, 1.0);
@define-color text #$TEXT;
@define-color accent #$ACCENT;
@define-color inactive #$INACTIVE;
@define-color urgent #$URGENT;
EOF

cat > "$DIR/colors.rasi" << EOF
* {
    bg:                          #$BACKGROUND;
    foreground-color:            #$TEXT;
    foreground-color-alt:        #$ACCENT;
    accent-color:                #$ACCENT;
    border-color:                #$ACCENT;
    on:                          #$ACCENT;
    off:                         #$INACTIVE;
    urgent:                      #$URGENT;
}
EOF

cat > "$DIR/hyprland-colors.conf" << EOF
# Auto-generated from colors.sh
\$background = rgba(${BACKGROUND}ee)
\$text = rgb($TEXT)
\$accent = rgb($ACCENT)
\$inactive = rgb($INACTIVE)
\$urgent = rgb($URGENT)
EOF

echo "Wrote colors.css, colors.rasi, hyprland-colors.conf"

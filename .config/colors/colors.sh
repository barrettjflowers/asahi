#!/bin/bash
# One source of truth — edit the 5 hex values below, then run ./colors.sh

BACKGROUND="20202A"
TEXT="B5BBC7"
ACCENT="696980"
INACTIVE="404042"
URGENT="f53c3c"

DIR="$(cd "$(dirname "$0")" && pwd)"

BG_R=$((16#${BACKGROUND:0:2}))
BG_G=$((16#${BACKGROUND:2:2}))
BG_B=$((16#${BACKGROUND:4:2}))

cat > "$DIR/colors.css" << EOF
@define-color background rgba($BG_R, $BG_G, $BG_B, 0.30);
@define-color text #$TEXT;
@define-color accent #$ACCENT;
@define-color inactive #$INACTIVE;
@define-color urgent #$URGENT;
EOF

cat > "$DIR/colors.rasi" << EOF
* {
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

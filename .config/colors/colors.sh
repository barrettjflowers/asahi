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

# 87% alpha for swayosd background, 50% for trough
BG_ALPHA_DD=$(printf '%02x' $(( 221 )))
TEXT_ALPHA_7F=$(printf '%02x' $(( 127 )))

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

mkdir -p ~/.config/swayosd
cat > ~/.config/swayosd/style.css << CSSEOF
window#osd {
  border-radius: 10px;
  border: 2px solid #$ACCENT;
  background: #${BACKGROUND}${BG_ALPHA_DD};

  #container {
    margin: 16px;
  }

  image,
  label {
    color: #$TEXT;
  }

  progressbar:disabled,
  image:disabled {
    opacity: 0.5;
  }

  progressbar,
  segmentedprogress {
    min-height: 6px;
    border-radius: 999px;
    background: transparent;
    border: none;
  }
  trough,
  segment {
    min-height: inherit;
    border-radius: inherit;
    border: none;
    background: #${TEXT}${TEXT_ALPHA_7F};
  }
  progress,
  segment.active {
    min-height: inherit;
    border-radius: inherit;
    border: none;
    background: #$TEXT;
  }

  segment {
    margin-left: 8px;
    &:first-child {
      margin-left: 0;
    }
  }
}
CSSEOF

echo "Wrote colors.css, colors.rasi, hyprland-colors.conf, swayosd/style.css"

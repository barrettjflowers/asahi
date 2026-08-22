#!/bin/bash
# One source of truth — edit the 5 hex values below, then run ./colors.sh

BACKGROUND="1C1A14"
TEXT="68694F"
ACCENT="737458"
INACTIVE="2C2A24"
URGENT="f53c3c"

DIR="$(cd "$(dirname "$0")" && pwd)"

BG_R=$((16#${BACKGROUND:0:2}))
BG_G=$((16#${BACKGROUND:2:2}))
BG_B=$((16#${BACKGROUND:4:2}))

TEXT_R=$((16#${TEXT:0:2}))
TEXT_G=$((16#${TEXT:2:2}))
TEXT_B=$((16#${TEXT:4:2}))

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
  background: rgba($BG_R, $BG_G, $BG_B, 0.87);
}

window#osd #container {
  margin: 16px;
}

window#osd image,
window#osd label {
  color: rgba($TEXT_R, $TEXT_G, $TEXT_B, 1);
}

window#osd progressbar:disabled,
window#osd image:disabled {
  opacity: 0.5;
}

window#osd progressbar,
window#osd segmentedprogress {
  min-height: 6px;
  border-radius: 999px;
  background: transparent;
  border: none;
}

window#osd trough,
window#osd segment {
  min-height: 6px;
  border-radius: 999px;
  border: none;
  background: rgba($TEXT_R, $TEXT_G, $TEXT_B, 0.5);
}

window#osd progress,
window#osd segment.active {
  min-height: 6px;
  border-radius: 999px;
  border: none;
  background: rgba($TEXT_R, $TEXT_G, $TEXT_B, 1);
}

window#osd segment {
  margin-left: 8px;
}

window#osd segment:first-child {
  margin-left: 0;
}
CSSEOF

echo "Wrote colors.css, colors.rasi, hyprland-colors.conf, swayosd/style.css"

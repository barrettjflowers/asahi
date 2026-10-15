#!/bin/bash
OUTDIR=$HOME/Pictures/Screenshots
mkdir -p "$OUTDIR"

GEOM=$(slurp) || exit 0
FILE="$OUTDIR/screenshot-$(date +%Y%m%d-%H%M%S).png"

grim -g "$GEOM" "$FILE" && wl-copy --type image/png < "$FILE"

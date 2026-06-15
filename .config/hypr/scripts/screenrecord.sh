#!/bin/bash
PIDFILE=/tmp/wf-recorder-pid
LOOP1_PIDFILE=/tmp/wf-recorder-loop1-pid
LOOP2_PIDFILE=/tmp/wf-recorder-loop2-pid
NULL_MODULE_FILE=/tmp/wf-recorder-null-module
OUTDIR=$HOME/Pictures/Screenshots
COMBINED_SINK=combined_record

if [ -f "$PIDFILE" ]; then
    kill "$(cat "$PIDFILE")" 2>/dev/null
    kill "$(cat "$LOOP1_PIDFILE")" 2>/dev/null
    kill "$(cat "$LOOP2_PIDFILE")" 2>/dev/null
    pactl unload-module "$(cat "$NULL_MODULE_FILE")" 2>/dev/null
    rm -f "$PIDFILE" "$LOOP1_PIDFILE" "$LOOP2_PIDFILE" "$NULL_MODULE_FILE" /tmp/wf-recorder-pid
    exit 0
fi

mkdir -p "$OUTDIR"
OUTFILE="$OUTDIR/recording_$(date +%Y%m%d_%H%M%S).mp4"

# Create null sink to combine desktop audio + mic
pactl load-module module-null-sink sink_name=$COMBINED_SINK > "$NULL_MODULE_FILE"

# Route desktop audio to combined sink
setsid pw-loopback \
    --capture-props='node.name="alsa_output.platform-sound.HiFi__Headphones__sink.monitor"' \
    --playback-props='node.target="'$COMBINED_SINK'"' \
    &>/dev/null &
echo $! > "$LOOP1_PIDFILE"

# Route mic to combined sink
setsid pw-loopback \
    --capture-props='node.name="alsa_input.platform-sound.HiFi__Headset__source"' \
    --playback-props='node.target="'$COMBINED_SINK'"' \
    &>/dev/null &
echo $! > "$LOOP2_PIDFILE"

sleep 0.3

wf-recorder --audio="${COMBINED_SINK}.monitor" -c libopenh264 -C aac -f "$OUTFILE" &
echo $! > "$PIDFILE"

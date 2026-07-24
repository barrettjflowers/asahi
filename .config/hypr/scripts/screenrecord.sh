#!/bin/bash
PIDFILE=/tmp/wf-recorder-pid
LOOP1_PIDFILE=/tmp/wf-recorder-loop1-pid
LOOP2_PIDFILE=/tmp/wf-recorder-loop2-pid
NULL_MODULE_FILE=/tmp/wf-recorder-null-module
REMAP_MODULE_FILE=/tmp/wf-recorder-remap-module
OUTDIR=$HOME/Pictures/Screenshots
COMBINED_SINK=combined_record

if [ -f "$PIDFILE" ]; then
    kill "$(cat "$PIDFILE")" 2>/dev/null
    kill "$(cat "$LOOP1_PIDFILE")" 2>/dev/null
    kill "$(cat "$LOOP2_PIDFILE")" 2>/dev/null
    pactl unload-module "$(cat "$REMAP_MODULE_FILE")" 2>/dev/null
    pactl unload-module "$(cat "$NULL_MODULE_FILE")" 2>/dev/null
    rm -f "$PIDFILE" "$LOOP1_PIDFILE" "$LOOP2_PIDFILE" "$NULL_MODULE_FILE" "$REMAP_MODULE_FILE"
    exit 0
fi

mkdir -p "$OUTDIR"
OUTFILE="$OUTDIR/$(date +%a_%d_%b_%H%M).mp4"

# Create null sink to combine desktop audio + mic
pactl load-module module-null-sink sink_name=$COMBINED_SINK > "$NULL_MODULE_FILE"

# Create stereo remapped source from mono mic (duplicates mono to both L+R)
pactl load-module module-remap-source \
    master=alsa_input.platform-sound.HiFi__Headset__source \
    source_name=mic_stereo \
    channels=2 \
    channel_map=front-left,front-right > "$REMAP_MODULE_FILE"

# Route desktop audio to combined sink
setsid pw-loopback \
    --capture-props='node.name="alsa_output.platform-sound.HiFi__Headphones__sink.monitor"' \
    --playback-props='node.target="'$COMBINED_SINK'"' \
    &>/dev/null &
echo $! > "$LOOP1_PIDFILE"

# Route stereo mic to combined sink
setsid pw-loopback \
    --capture-props='node.name="mic_stereo"' \
    --playback-props='node.target="'$COMBINED_SINK'"' \
    &>/dev/null &
echo $! > "$LOOP2_PIDFILE"

sleep 0.3

wf-recorder --audio="${COMBINED_SINK}.monitor" -c libopenh264 -C aac -f "$OUTFILE" &
echo $! > "$PIDFILE"

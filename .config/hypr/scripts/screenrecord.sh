#!/bin/bash
# Toggle screen recording with desktop audio + mic mixed into one track.
# Uses only PipeWire tools (no pactl). Every link targets the mix sink with
# node.dont-reconnect, so nothing can fall back to the speakers and feed back.
PIDFILE=/tmp/wf-recorder-pid
LOOPS_PIDFILE=/tmp/wf-recorder-loops-pid
OUTDIR=$HOME/Pictures/Screenshots
MIX=combined_record

if [ -f "$PIDFILE" ]; then
    kill "$(cat "$PIDFILE")" 2>/dev/null
    sleep 0.5   # let wf-recorder finalize the file before its source disappears
    kill $(cat "$LOOPS_PIDFILE") 2>/dev/null
    rm -f "$PIDFILE" "$LOOPS_PIDFILE"
    exit 0
fi

mkdir -p "$OUTDIR"
OUTFILE="$OUTDIR/$(date +%a_%d_%b_%H%M).mp4"

# Mix bus: a virtual sink whose output is exposed as the source "${MIX}_src"
pw-loopback -n "$MIX" \
    --capture-props="media.class=Audio/Sink node.name=$MIX node.description=Recording-mix" \
    --playback-props="media.class=Audio/Source node.name=${MIX}_src node.description=Recording-mix-source" \
    &>/dev/null &
PIDS=$!
sleep 0.3

# Desktop audio: monitor of the default sink -> mix
pw-loopback -n "${MIX}_desktop" \
    --capture-props="stream.capture.sink=true" \
    --playback-props="target.object=$MIX node.dont-reconnect=true" \
    &>/dev/null &
PIDS="$PIDS $!"

# Mic: default source, mono, fanned out to both channels of the mix
pw-loopback -n "${MIX}_mic" \
    --playback-props="target.object=$MIX node.dont-reconnect=true" \
    &>/dev/null &
PIDS="$PIDS $!"
echo "$PIDS" > "$LOOPS_PIDFILE"
sleep 0.3

# The mic is mono, so it only gets linked to FL; link it to FR as well
MIC_PORT=$(pw-link -l | awk -v p="input.${MIX}_mic:input_FL" '$0==p{getline; print $2; exit}')
[ -n "$MIC_PORT" ] && pw-link "$MIC_PORT" "input.${MIX}_mic:input_FR" 2>/dev/null

wf-recorder --audio="${MIX}_src" -c libopenh264 -C aac -f "$OUTFILE" &
echo $! > "$PIDFILE"

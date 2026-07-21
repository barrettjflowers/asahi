#!/bin/bash
PIDFILE=/tmp/transcribe-pid

if [ -f "$PIDFILE" ]; then
    kill "$(cat "$PIDFILE")" 2>/dev/null
    rm "$PIDFILE"
    notify-send "Transcribing..." ""

    text=$(python3 -c "
from faster_whisper import WhisperModel
model = WhisperModel('base', device='cpu', compute_type='int8')
segments, _ = model.transcribe('/tmp/transcribe.wav', language='en')
print(' '.join(s.text for s in segments))
")
    rm -f /tmp/transcribe.wav

    echo -n "$text" | wl-copy
    notify-send "Copied to clipboard" "$text"
    exit 0
fi

notify-send "Recording..." ""
pactl set-source-mute effect_output.j413-mic 0
pactl set-source-volume effect_output.j413-mic 150%
amixer -c 1 cset name='Jack ADC PGA' 24 2>/dev/null
amixer -c 1 cset name='Jack ADC Preamp' 2 2>/dev/null
ffmpeg -f pulse -i effect_output.j413-mic -ac 1 -ar 16000 -sample_fmt s16 /tmp/transcribe.wav -y &
echo $! > "$PIDFILE"

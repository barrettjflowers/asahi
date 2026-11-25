#!/bin/bash
# No args: toggle speaking the clipboard (Super+Shift+T).
# "-": speak stdin silently, replacing anything already playing (Claude Code speak plugin).
# Playback runs as the transient user unit voice-agent, so it outlives whatever started it.
UNIT=voice-agent
# Local Kokoro-82M TTS (kokoro-onnx), installed in ~/.local/share/kokoro (venv + models).
# A voice or a weighted blend, e.g. "bf_emma" or "bf_emma:0.6,af_heart:0.4".
VOICE="${VOICE_AGENT_VOICE:-bf_emma:0.6,af_heart:0.4}"
SPEED="${VOICE_AGENT_SPEED:-1.0}"
LANG_CODE="${VOICE_AGENT_LANG:-en-gb}"
KOKORO=/home/barrettjflowers/.local/share/kokoro
PY="$KOKORO/venv/bin/python"
[ -x "$PY" ] || { notify-send "Voice agent" "Kokoro venv not found"; exit 1; }
MPV=$(command -v mpv) || { notify-send "Voice agent" "mpv not found"; exit 1; }

STDIN=0
[ "$1" = "-" ] && STDIN=1

if systemctl --user is-active --quiet "$UNIT"; then
    systemctl --user stop "$UNIT"
    if [ "$STDIN" = 0 ]; then
        notify-send "Voice agent" "Stopped"
        exit 0
    fi
fi

if [ "$STDIN" = 1 ]; then
    text=$(cat)
    [ -z "$text" ] && exit 0
else
    text=$(wl-paste 2>/dev/null)
    [ -z "$text" ] && { notify-send "Voice agent" "Clipboard empty"; exit 0; }
fi

text="${text#"${text%%[![:space:]]*}"}"
text="${text%"${text##*[![:space:]]}"}"

file=$(mktemp "${XDG_RUNTIME_DIR:-/tmp}/voice-agent.XXXXXX")
printf '%s' "$text" > "$file"

# Split into sentence chunks (short first one) so playback starts quickly;
# a worker thread synthesizes ahead while mpv plays raw float32 PCM.
read -r -d '' PLAYER <<'PY'
import os, queue, re, subprocess, sys, threading
from kokoro_onnx import Kokoro

voice, speed, lang, models, path, mpv = sys.argv[1:7]
with open(path) as f:
    text = f.read()
os.unlink(path)

chunks, cur = [], ""
for part in re.split(r"(?<=[.!?;:])\s+|\n+", text):
    part = part.strip()
    if not part:
        continue
    limit = 300 if chunks else 80
    if cur and len(cur) + len(part) > limit:
        chunks.append(cur)
        cur = part
    else:
        cur = f"{cur} {part}".strip()
if cur:
    chunks.append(cur)
if not chunks:
    sys.exit(0)

kokoro = Kokoro(f"{models}/kokoro-v1.0.onnx", f"{models}/voices-v1.0.bin")
if ":" in voice:
    style = 0
    for part in voice.split(","):
        name, weight = part.split(":")
        style = style + kokoro.get_voice_style(name.strip()) * float(weight)
    voice = style
q = queue.Queue(maxsize=3)

def worker():
    for c in chunks:
        try:
            samples, _ = kokoro.create(c, voice=voice, speed=float(speed), lang=lang)
            q.put(samples.astype("float32").tobytes())
        except Exception:
            q.put(b"")
    q.put(None)

threading.Thread(target=worker, daemon=True).start()
player = subprocess.Popen(
    [mpv, "--no-video", "--really-quiet", "--force-media-title=Voice agent",
     "--demuxer=rawaudio", "--demuxer-rawaudio-format=floatle",
     "--demuxer-rawaudio-rate=24000", "--demuxer-rawaudio-channels=1", "-"],
    stdin=subprocess.PIPE, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
while (audio := q.get()) is not None:
    player.stdin.write(audio)
    player.stdin.flush()
player.stdin.close()
player.wait()
PY

[ "$STDIN" = 0 ] && notify-send "Voice agent" "Speaking clipboard..."
systemd-run --user --quiet --collect --unit="$UNIT" \
    "$PY" -P -c "$PLAYER" "$VOICE" "$SPEED" "$LANG_CODE" "$KOKORO/models" "$file" "$MPV"

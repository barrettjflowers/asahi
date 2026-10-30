#!/bin/bash
# No args: toggle speaking the clipboard (Super+Shift+T).
# "-": speak stdin silently, replacing anything already playing (Claude Code speak plugin).
# Playback runs as the transient user unit voice-agent, so it outlives whatever started it.
UNIT=voice-agent
VOICE="${VOICE_AGENT_VOICE:-en-IE-EmilyNeural}"
RATE="${VOICE_AGENT_RATE:-+0%}"
EDGE_TTS=/home/barrettjflowers/.local/bin/edge-tts
[ -x "$EDGE_TTS" ] || { notify-send "Voice agent" "edge-tts not found"; exit 1; }
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

# edge-tts only sends audio once a whole request is synthesized, so long text
# starts late. Split into sentence chunks (short first one), synthesize a few
# ahead in parallel, and feed them to mpv in order.
read -r -d '' PLAYER <<'PY'
import asyncio, os, re, sys
import edge_tts

voice, rate, path, mpv = sys.argv[1:5]
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

async def synth(chunk):
    audio = bytearray()
    try:
        async for msg in edge_tts.Communicate(chunk, voice, rate=rate).stream():
            if msg["type"] == "audio":
                audio += msg["data"]
    except Exception:
        pass
    return bytes(audio)

async def main():
    if not chunks:
        return
    player = await asyncio.create_subprocess_exec(
        mpv, "--no-video", "--really-quiet", "--force-media-title=Voice agent", "-",
        stdin=asyncio.subprocess.PIPE,
        stdout=asyncio.subprocess.DEVNULL, stderr=asyncio.subprocess.DEVNULL)
    ahead = 3
    tasks = [asyncio.create_task(synth(c)) for c in chunks[:ahead]]
    for i in range(len(chunks)):
        audio = await tasks[i]
        if i + ahead < len(chunks):
            tasks.append(asyncio.create_task(synth(chunks[i + ahead])))
        player.stdin.write(audio)
        await player.stdin.drain()
    player.stdin.close()
    await player.wait()

asyncio.run(main())
PY

[ "$STDIN" = 0 ] && notify-send "Voice agent" "Speaking clipboard..."
systemd-run --user --quiet --collect --unit="$UNIT" \
    /usr/bin/python3 -P -c "$PLAYER" "$VOICE" "$RATE" "$file" "$MPV"

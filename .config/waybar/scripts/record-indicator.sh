#!/bin/bash
if [ -f /tmp/wf-recorder-pid ]; then
    echo '{"text": "  REC", "class": "recording"}'
else
    echo '{"text": "", "class": "idle"}'
fi

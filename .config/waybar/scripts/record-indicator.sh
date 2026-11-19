#!/bin/bash
if [ -f /tmp/wf-recorder-pid ]; then
    echo '{"text": " Rec", "class": "recording"}'
else
    echo '{"text": "", "class": "idle"}'
fi

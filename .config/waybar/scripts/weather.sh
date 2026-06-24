#!/bin/bash
curl -s "wttr.in/Indianapolis?format=%t&u" | tr -d '+'

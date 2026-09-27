#!/bin/bash
awk '/^MemTotal:/{t=$2} /^MemAvailable:/{a=$2} END{printf "%.1f\n", (t-a)*1024/1e9}' /proc/meminfo

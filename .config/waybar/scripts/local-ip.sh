#!/bin/bash
ip -4 addr show scope global | awk '/inet /{print $2}' | cut -d/ -f1 | head -1
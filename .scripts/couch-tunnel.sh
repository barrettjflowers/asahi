#!/usr/bin/env zsh
# Tunnel to the CouchDB container on an igw host and print the Fauxton link.
# Usage: couch <ssh-host> [local-port]    (Ctrl-C closes the tunnel)

host=$1
lport=${2:-5984}

if [[ -z $host ]]; then
  echo "usage: ${0:t} <ssh-host> [local-port]" >&2
  exit 1
fi

# Step up past any local port that's already in use (e.g. a second tunnel)
while ss -Hltn "sport = :$lport" | grep -q .; do (( lport++ )); done

ip=$(ssh -o ConnectTimeout=8 "$host" '
  D=docker; $D ps >/dev/null 2>&1 || D="sudo -n docker"
  c=$($D ps -qf name=^couchdb | head -1)
  [ -n "$c" ] && $D inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}} {{end}}" "$c"
' | awk '{print $1}')

if [[ -z $ip ]]; then
  echo "${0:t}: no running couchdb container found on $host" >&2
  exit 1
fi

echo "CouchDB on $host ($ip:5984)"
echo "→ http://localhost:$lport/_utils/"
echo "Ctrl-C to close"
exec ssh -N -o ExitOnForwardFailure=yes -L "$lport:$ip:5984" "$host"

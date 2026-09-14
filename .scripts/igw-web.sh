#!/usr/bin/env zsh
# Tunnel to the igw web UI on a local-stack box and print the links.
# Usage: igw-web [ssh-host]    (default: igw-local-remote; Ctrl-C closes the tunnel)

host=${1:-igw-local-remote}
base=http://localhost:3080

# The app expects port 3080, so don't move it; if it's taken, a tunnel is probably already open
if ss -Hltn "sport = :3080" | grep -q .; then
  echo "${0:t}: localhost:3080 is already in use (tunnel already open?)" >&2
  echo "→ $base/super" >&2
  exit 1
fi

echo "igw web UI on $host"
echo "→ Super Admin (v3):  $base/super"
echo "→ Merchant login:    $base/a/login"
echo "→ Traefik dashboard: http://localhost:3081/dashboard/"
echo "Ctrl-C to close"
exec ssh -N -o ExitOnForwardFailure=yes -L 3080:localhost:3080 -L 3081:localhost:3081 "$host"


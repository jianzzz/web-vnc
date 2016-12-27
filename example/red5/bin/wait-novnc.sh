#!/usr/bin/env bash

# set -e: exit asap if a command exits with a non-zero status
set -e
 
echo -n "Waiting for noVNC to be ready..."
while ! curl -s "http://localhost:${NOVNC_PORT}/vnc.html" \
          | grep "noVNC_screen"; do
  echo -n '.'
  sleep 0.1
done
echo -n "Done wait-novnc.sh"

#!/usr/bin/env bash

# set -e: exit asap if a command exits with a non-zero status
set -e

echo -n "Waiting for Xvfb to be ready..."
echo -n "-- INFO: Will try to xdpyinfo at DISPLAY=${DISPLAY}" 
while ! xdpyinfo -display ${DISPLAY}; do
  echo -n ''
  sleep 0.1
done

echo -n "Done wait-xvfb.sh"

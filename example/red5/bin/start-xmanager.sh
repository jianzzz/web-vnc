#!/usr/bin/env bash

# set -e: exit asap if a command exits with a non-zero status
set -e

echoerr() { printf "%s\n" "$*" >&2; }

# print error and exit
die () {
  echoerr "ERROR: $1"
  # if $2 is defined AND NOT EMPTY, use $2; otherwise, set to "150"
  errnum=${2-110}
  exit $errnum
}

# Wait for this process dependencies
timeout --foreground ${WAIT_TIMEOUT} wait-xvfb.sh

function shutdown {
  echo -n "Trapped SIGTERM/SIGINT so shutting down $0 gracefully..."
  exit 0
}

# Run function shutdown() when this process receives a killing signal
# trap shutdown SIGTERM SIGINT SIGKILL
 
if [ "${XMANAGER}" = "openbox" ]; then
  # Openbox is a lightweight window manager using freedesktop standards
  openbox 1> "${LOGS_DIR}/openbox-tryouts-stdout.log" 2> "${LOGS_DIR}/openbox-tryouts-stderr.log" &
else
  die "The chosen X manager is not supported: '${XMANAGER}'"
fi

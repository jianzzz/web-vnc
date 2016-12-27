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

function start_fluxbox() {
  # http://stackoverflow.com/a/21028200/511069
  echo -n "-- INFO: Will try to start fluxbox at DISPLAY=${DISPLAY}"  
  fluxbox -display "${DISPLAY}.0" -verbose \
    1> "${LOGS_DIR}/fluxbox-tryouts-stdout.log" \
    2> "${LOGS_DIR}/fluxbox-tryouts-stderr.log" &
}

if [ "${XMANAGER}" = "openbox" ]; then
  # Openbox is a lightweight window manager using freedesktop standards 
  openbox 1> "${LOGS_DIR}/openbox-tryouts-stdout.log" 2> "${LOGS_DIR}/openbox-tryouts-stderr.log" &
elif [ "${XMANAGER}" = "fluxbox" ]; then
  # Fluxbox is a fast, lightweight and responsive window manager

  # Race conditions are possible for the port range lookup
  # so try again
  i=0
  stat_failed=true
  while true ; do
    while true ; do
      let i=${i}+1
      if ! start_fluxbox; then
        echo -n "-- WARN: start_fluxbox() failed!"
      fi
      if timeout --foreground "${WAIT_FOREGROUND_RETRY}" wait-xmanager.sh &> "${LOGS_DIR}/wait-xmanager-stdout.log"; then
        stat_failed=false
        break
      else
        echo -n "-- WARN: wait-xmanager.sh failed! for DISPLAY=${DISPLAY}"
        killall fluxbox || true
      fi
      if [ ${i} -gt ${FLUXBOX_START_MAX_RETRIES} ]; then
        echoerr "-- ERROR: Failed to start Fluxbox at $0 after many retries."
        break
      fi
    done
    [ "${stat_failed}" != "true" ] && wait
    stat_failed=true
  done
else
  die "The chosen X manager is not supported: '${XMANAGER}'"
fi

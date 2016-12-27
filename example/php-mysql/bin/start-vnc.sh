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
timeout --foreground ${WAIT_TIMEOUT} wait-xmanager.sh

function shutdown {
  echo -n "Trapped SIGTERM/SIGINT so shutting down $0 gracefully..."
  exit 0
}

# Run function shutdown() when this process receives a killing signal
# trap shutdown SIGTERM SIGINT SIGKILL

# Wait for this process dependencies
timeout --foreground ${WAIT_TIMEOUT} wait-xvfb.sh
timeout --foreground ${WAIT_TIMEOUT} wait-xmanager.sh

# Start VNC server to enable viewing what's going on but not mandatory
# -rfbport  port TCP port for RFB protocol
# -rfbauth  passwd-file, use authentication on RFB protocol
# -viewonly all VNC clients can only watch (default off).
# -forever  keep listening for more connections rather than exiting as soon
#           as the first client(s) disconnect.
# -usepw    first look for ~/.vnc/passwd then -rfbauth or prompt for pwd
# -shared   more than one viewer can connect at the same time (default off)
# -noadd_keysyms add the Keysym to X srv keybd mapping on an unused key.
#           Default: -add_keysyms
# -nopw     disable the warn msg when running without some sort of password
# -xkb      when in modtweak mode, use the XKEYBOARD extension
# -clear_mods used to clear the state if the display was accidentally left
#           with any pressed down.
# -clear_keys As -clear_mods, except try to release ANY pressed key
# -clear_all  As -clear_keys, except try to release any CapsLock, NumLock ...
#
# Redirecting to >/dev/null until https://github.com/LibVNC/x11vnc/issues/14
export VNC_PID="9999" 
function start_vnc() { 
  # http://stackoverflow.com/a/21028200/511069
  echo -n "-- INFO: Will try to x11vnc at DISPLAY=${DISPLAY}"  
  x11vnc -forever -shared \
    -rfbport ${VNC_PORT} \
    -rfbportv6 ${VNC_PORT} \
    -display ${DISPLAY} ${VNC_AUTH_OPTS} \
    1> "${LOGS_DIR}/vnc-tryouts-stdout.${VNC_PORT}.log" \
    2> "${LOGS_DIR}/vnc-tryouts-stderr.${VNC_PORT}.log" &
  export VNC_PID=$!
}

if [ "${VNC_PASSWORD}" = "no" ]; then
  export VNC_AUTH_OPTS="-auth /var/run/slim.auth"
else
  if [ -z "${VNC_PASSWORD}" ]; then
    random_password=$(genpassword.sh)
    export VNC_PASSWORD=${random_password}
    echo -n "a VNC password was generated for you: $VNC_PASSWORD"
  fi
  # Generate the password file
  x11vnc -storepasswd ${VNC_PASSWORD} ${VNC_STORE_PWD_FILE}
  export VNC_AUTH_OPTS="-rfbauth ${VNC_STORE_PWD_FILE}"
  # update system variable
  echo "export VNC_PASSWORD=${VNC_PASSWORD}" >> /root/.bashrc 
fi
 

echo "${VNC_PORT}" > VNC_PORT
stat_failed=true
if ! start_vnc; then
  echo -n "-- WARN: start_vnc() failed!"
fi
if timeout --foreground "${WAIT_VNC_FOREGROUND_RETRY}" wait-vnc.sh; then
  stat_failed=false 
else
  echo -n "-- WARN: wait-vnc.sh failed! for VNC_PORT=${VNC_PORT}"
  # killall x11vnc || true
  kill ${VNC_PID}
fi 

if [ "${stat_failed}" = "true" ]; then
  echoerr "Reached the end of $0 either graceful shutdown or something went wrong:"
  die "VNC_PORT=${VNC_PORT} VNC_FROM_PORT=${VNC_FROM_PORT} VNC_TO_PORT=${VNC_TO_PORT}"
else
  wait
fi

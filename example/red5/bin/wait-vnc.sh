#!/usr/bin/env bash

# set -e: exit asap if a command exits with a non-zero status
set -e

export VNC_PORT="${VNC_PORT}"
LOGSDTOUT="${LOGS_DIR}/vnc-tryouts-stdout.${VNC_PORT}.log"
LOGERR="${LOGS_DIR}/vnc-tryouts-stderr.${VNC_PORT}.log"
 
fail_fast() {
  # killall x11vnc || true
  exit 3
}
 
# Note this active wait provokes below error, so ignore it
#  "webSocketsHandshake: unknown connection error"

echo -n "Waiting for VNC to be ready via process, nc or netstat on VNC_PORT=${VNC_PORT}..."
echo -n 'By_process.'
while ! pgrep -f x11vnc >/dev/null 2>&1; do
  echo -n '.'
  sleep 0.1
  if grep "ListenOnTCPPort: Address already in use" ${LOGERR}; then
    fail_fast
  elif grep "could not obtain listening port" ${LOGERR}; then
    fail_fast
  elif grep "bind: Permission denied" ${LOGERR}; then
    fail_fast
  fi
done; echo -n 'OK...'
#echo -n 'By_nc.'
#while ! nc -z localhost ${VNC_PORT}; do
#  echo -n '.'
#  sleep 0.1
#  if grep "ListenOnTCPPort: Address already in use" ${LOGERR}; then
#    fail_fast
#  elif grep "could not obtain listening port" ${LOGERR}; then
#    fail_fast
#  elif grep "bind: Permission denied" ${LOGERR}; then
#    fail_fast
#  fi
#done; echo -n 'OK...'
echo -n 'By_netstat.'
while ! netstat -an | \
        grep "LISTEN" | \
        grep ":${VNC_PORT} " >/dev/null 2>&1; do
  echo -n '.'
  sleep 0.1
done; echo -n 'OK...'

echo -n 'By_log_stderr.'
while ! grep " VNC desktop is: " ${LOGERR}; do
  echo -n '.'
  sleep 0.1
  if grep "bind: Address already in use" ${LOGERR}; then
    fail_fast
  elif grep "could not obtain listening port" ${LOGERR}; then
    fail_fast
  elif grep "bind: Permission denied" ${LOGERR}; then
    fail_fast
  fi
#  nc -z localhost ${VNC_PORT}
#  netstat -an | grep "LISTEN" | grep ":${VNC_PORT} "
done; echo -n 'OK...'

echo -n 'By_log_stdout.'
while ! grep "PORT=${VNC_PORT}" ${LOGSDTOUT}; do
  echo -n '.'
  sleep 0.1
done; echo -n 'OK...'


echo -n "Done wait-vnc.sh"

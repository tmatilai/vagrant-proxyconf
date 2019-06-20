#!/bin/bash
set -ex

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

start() {
  # start ssh if sshd is installed
  if [ -f /usr/sbin/sshd ]; then

    /usr/sbin/sshd-keygen
    /usr/sbin/sshd -t
    /usr/sbin/sshd

  else

    true

  fi

  # start tinyproxy
  /usr/sbin/tinyproxy \
    -d \
    -c "/etc/tinyproxy/tinyproxy.conf"
}

stop() {

  pgrep -f 'sshd' | while read _pid
  do
    kill -9 $_pid
  done

  pgrep -f 'tinyproxy' | while read _pid
  do
    kill -9 $_pid
  done

}

case "${1}" in

  start)
    start
    ;;

  stop)
    stop
    ;;

esac

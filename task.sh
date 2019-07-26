#!/bin/bash

set -o errexit -o pipefail

# Don't run anything before this source as it sets PATH here
# shellcheck disable=SC1091
source /etc/profile

finish_up() {
    local failure=$1
    local exit_code=0
    if [ -n "${failure}" ]; then
        echo "Fail: ${failure}"
        exit_code=1
    else
        echo "DONE"
    fi
    sleep 2
    exit ${exit_code}
}

main() {
    if ! systemctl restart resin-supervisor ; then
        echo "First restart attempt didn't work, trying with balenaEngine restart"
        systemctl stop resin-supervisor || finish_up "Couldn't stop supervisor."
        systemctl stop balena || finish_up "Couldn't stop balena."
        systemctl start balena || finish_up "Couldn't start up balena."
        systemctl start resin-supervisor || finish_up "Couldn't start up supervisor."
    fi

    sleep 10
    if ! balena ps | grep -q resin_supervisor ; then
        finish_up "Supervisor not restarted properly after while."
    fi

    finish_up
}

(
  # Check if already running and bail if yes
  flock -n 99 || (echo "Already running script..."; exit 1)
  main
) 99>/tmp/task.lock
# Proper exit, required due to the locking subshell
exit $?

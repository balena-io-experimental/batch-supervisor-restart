#!/usr/bin/env bash

# shellcheck disable=SC2002
cat batch | stdbuf -oL xargs -I{} -P 30 /bin/sh -c "cat task.sh | balena ssh {} | sed 's/^/{} : /' | tee -a task.log"

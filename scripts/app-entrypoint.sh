#!/bin/bash

# Executes command using provided user-name and group-name
# Parameters:
#   APP_USERNAME
#   [OPTIONAL] APP_GROUPNAME

# Debug output
set -x

# Exit on error
set -e

: "${APP_USERNAME:?Variable not set or empty}"

if [[ "$(id -u)" != "$(id -u $APP_USERNAME)" || (-n "$APP_GROUPNAME" && "$(id -g)" != "$(getent group $APP_GROUPNAME | cut -d: -f3)") ]]; then
  if [ -n "$APP_GROUPNAME" ]; then
    exec su-exec "$APP_USERNAME:$APP_GROUPNAME" "$BASH_SOURCE" "$@"
  else
    exec su-exec "$APP_USERNAME" "$BASH_SOURCE" "$@"
  fi
fi

exec "$@"
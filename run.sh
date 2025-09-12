#!/bin/bash

# Exit on error
set -e

# Load functions
source /scripts/update-app-user-uid-gid.sh

# Debug output
set -x

update_user_gid $APP_USERNAME $APP_GROUPNAME $APP_GID
update_user_uid $APP_USERNAME $APP_UID

if [ "$1" = $APP_NAME ]; then
  shift;
  exec /scripts/app-entrypoint.sh $APP_BIN "$@"
fi

exec "$@"

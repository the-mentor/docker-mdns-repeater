#!/bin/bash

# Updates user to have specified GID
# Parameters:
#   USERNAME
#   GROUPNAME
#   GID
# Ex:
# update_user_gid my_user_name my_user_group 1000
update_user_gid () {
    # collect parameters
    _USERNAME=$1
    _GROUPNAME=$2
    _GID=$3
    #
    if [ -n "$_GID" ] && [ "$_GID" != "$(id $_USERNAME -g)" ]; then
        set +e
        # delete all users using requested GID
        cut -d: -f1,4 /etc/passwd | grep -w $_GID |
        while read name_gid
        do
            name=$(echo $name_gid | cut -d: -f1)
            deluser $name
        done
        # delete group with requested GID
        group=$(getent group $_GID | cut -d: -f1)
        if [ -n "$group" ]; then
            delgroup $group
        fi
        set -e
        # update GID
        groupmod --gid $_GID $_GROUPNAME
        usermod --gid $_GID $_USERNAME
    fi
}

# Updates user to have specified UID
# Parameters:
#   USERNAME
#   UID
# Ex:
# update_user_uid my_user_name 1000
update_user_uid () {
    # collect parameters
    _USERNAME=$1
    _UID=$2
    #
    if [ -n "$_UID" ] && [ "$_UID" != "$(id $_USERNAME -u)" ]; then
        set +e
        # delete all users using requested UID
        cut -d: -f1,3 /etc/passwd | grep -w $_UID |
        while read name_uid
        do
            name=$(echo $name_uid | cut -d: -f1)
            deluser $name
        done
        set -e
        #
        usermod --uid $_UID $_USERNAME
    fi
}
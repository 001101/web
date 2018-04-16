#!/bin/bash

# Setup

GROUPNAME="bitwarden"
USERNAME="bitwarden"

CURRENTGID=`getent group $GROUPNAME | cut -d: -f3`
LGID=${LOCAL_GID:-999}

CURRENTUID=`id -u $USERNAME`
NOUSER=`$CURRENTUID > /dev/null 2>&1; echo $?`
LUID=${LOCAL_UID:-999}

# Step down from host root

if [ $LGID == 0 ]
then
    LGID=999
fi

if [ $LUID == 0 ]
then
    LUID=999
fi

# Create group

if [ $CURRENTGID ]
then
    if [ $CURRENTGID != $LGID ]
    then
        groupmod -g $LGID $GROUPNAME
    fi
else
    groupadd -g $LGID $GROUPNAME
fi

# Create user and assign group

if [ $NOUSER == 0 ] && [ $CURRENTUID != $LUID ]
then
    usermod -u $LUID $USERNAME
elif [ $NOUSER == 1 ]
then
    useradd -r -u $LUID -g $GROUPNAME $USERNAME
fi

# Make home directory for user

if [ ! -d "/home/$USERNAME" ]
then
    mkhomedir_helper $USERNAME
fi

# The rest...

chown -R $USERNAME:$GROUPNAME /etc/bitwarden
cp /etc/bitwarden/web/settings.js /app/js/settings.js
cp /etc/bitwarden/web/app-id.json /app/app-id.json
chown -R $USERNAME:$GROUPNAME /app
chown -R $USERNAME:$GROUPNAME /bitwarden_server

gosu $USERNAME:$GROUPNAME dotnet /bitwarden_server/Server.dll \
    /contentRoot=/app /webRoot=. /serveUnknown=false

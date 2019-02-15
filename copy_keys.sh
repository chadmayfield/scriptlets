#!/bin/bash

# copy_keys.sh - copy ssh keys to a temp server

if [ $# -ne 1 ]; then
  echo "ERROR: Must supply the last IP octet!"
  exit 1
fi

IP="$1"
HOST="host${IP}.us.local"
USERS="root admin nimda toor"
PASS="Password1"
KEY="${HOME}/.ssh/temp/id_rsa"

command -v sshpass >/dev/null 2>&1 || \
  { echo >&2 "ERROR: 'sshpass' is required but it's not installed!"; exit 1; }

# remove any keys for this host from known hosts
if [ "$(ssh-keygen -F "$HOST")" ] ; then
  ssh-keygen -f "${HOME}/.ssh/known_hosts" -R $HOST
fi

# ssh-copy-id key to server
for i in ${USERS[@]}
do
  sshpass -p "$PASS" ssh-copy-id -f -i "${KEY}.pub" -o StrictHostKeyChecking=no ${i}@${HOST}
  # disable the TMOUT for ssh to we can stay connected
  ssh -i "$KEY" ${i}@${HOST} 'echo "# CHAD WAS HERE"; echo "unset TMOUT" >> ~/.bashrc'
done

#EOF

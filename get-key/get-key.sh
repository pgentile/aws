#!/bin/bash

# Use this script with OpenSSH server
#
#   Command to run:
#
#     # %u represents the user
#     AuthorizedKeysCommand /etc/ssh/get-key.sh %u
# 
#   User that runs the command:
#
#     AuthorizedKeysCommandUser nobody

set -e

user="$1"

aws iam list-ssh-public-keys --user "$user" | jq -r '.SSHPublicKeys[].SSHPublicKeyId' | while read key_id; do
  aws iam get-ssh-public-key --encoding SSH --user-name "$user" --ssh-public-key-id "$key_id" | jq -r '.SSHPublicKey.SSHPublicKeyBody'
done

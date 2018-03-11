#!/bin/bash

set -e

cp /tmp/get-ssh-key.sh /usr/libexec/get-ssh-key.sh

cat <<EOF >>/etc/ssh/sshd_config
# Get SSH keys from AWS IAM
AuthorizedKeysCommand /usr/libexec/get-ssh-key.sh %u
AuthorizedKeysCommandUser nobody
EOF

service sshd restart

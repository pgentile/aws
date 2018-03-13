#!/bin/bash

set -e

# Non interractive Debian frontend
export DEBIAN_FRONTEND=noninteractive

# Update packages
sudo apt-get update -y

# Install base packages
sudo apt-get install -y apt-transport-https dirmngr

# No translations
echo 'Acquire::Languages "none";' | sudo tee /etc/apt/apt.conf.d/99disable-translations

# Install Ansible ?
### No repository for stretch
### echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu stretch main" | sudo tee /etc/apt/sources.list.d/ansible.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367

# Install Lynis
echo "deb https://packages.cisofy.com/community/lynis/deb/ stretch main" | sudo tee /etc/apt/sources.list.d/cisofy-lynis.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C80E383C3DE9F082E01391A0366C67DE91CA5D5F

# Update packages
sudo apt-get update -y

# Upgrade system
sudo apt-get upgrade -y

# Install new packages
sudo apt-get install -y ansible lynis

# Hardening SSH
# TODO Default config should also be edited, some params in this config are not overriden
hardened_sshd_config_file=$(tempfile)
cat >$hardened_sshd_config_file <<EOF
# Hardened sshd config

# See https://www.ssh.com/ssh/sshd_config/
AllowTcpForwarding no
AllowStreamLocalForwarding no
GatewayPorts no
PermitTunnel no

ClientAliveCountMax 2
ClientAliveInterval 300
Compression no
LogLevel verbose
MaxSessions 2
PermitRootLogin no
TCPKeepAlive no
X11Forwarding no

# Disabled for now, because sshd rejects all connection attempts
# MaxAuthTries 2

# We can do that because we are not the bastion host
AllowAgentForwarding no

EOF

# And default config...
cat /etc/ssh/sshd_config >>$hardened_sshd_config_file

# Generate new sshd config 
sudo cat $hardened_sshd_config_file >/etc/ssh/sshd_config

# Restart SSH daemon
sudo systemctl restart sshd

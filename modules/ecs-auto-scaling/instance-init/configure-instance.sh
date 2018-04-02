#!/bin/bash

set -x
set -e

# Get the AWS region
REGION=$(curl -s "http://169.254.169.254/latest/dynamic/instance-identity/document" | jq -r ".region")

# Install chrony

yum -y erase ntp*
yum -y install chrony
service chronyd start
chkconfig chronyd on
chronyc sources -v

# Configure logs

mkdir -p /etc/awslogs/ || true

cat >/etc/awslogs/awscli.conf <<EOF
[default]
region = ${REGION}
[plugins]
cwlogs = cwlogs
EOF

cat >/etc/awslogs/awslogs.conf <<EOF
[general]
state_file = /var/lib/awslogs/agent-state

[/var/log/dmesg]
datetime_format = %Y-%m-%dT%H:%M:%S%z
file = /var/log/dmesg
initial_position = start_of_file
log_group_name = /var/log/dmesg
log_stream_name = {instance_id}

[/var/log/messages]
datetime_format = %Y-%m-%dT%H:%M:%S%z
file = /var/log/messages
initial_position = start_of_file
log_group_name = /var/log/messages
log_stream_name = {instance_id}

[/var/log/docker]
datetime_format = %Y-%m-%dT%H:%M:%S%z
file = /var/log/docker
initial_position = start_of_file
log_group_name = /var/log/docker
log_stream_name = {instance_id}

[/var/log/ecs/ecs-init.log]
datetime_format = %Y-%m-%dT%H:%M:%S%z
file = /var/log/ecs/ecs-init.log
initial_position = start_of_file
log_group_name = /var/log/ecs/ecs-init.log
log_stream_name = {instance_id}

[/var/log/ecs/ecs-agent.log]
datetime_format = %Y-%m-%dT%H:%M:%S%z
file = /var/log/ecs/ecs-agent.log.*
initial_position = start_of_file
log_group_name = /var/log/ecs/ecs-agent.log
log_stream_name = {instance_id}
EOF

service awslogs start
chkconfig awslogs on

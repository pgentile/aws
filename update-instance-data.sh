#!/bin/bash

set -e
set -x

# Nice script, but useless with CoreOS...

# Init user data and get the CoreOS AMI ID
terraform apply -target local_file.ignition_config -target data.aws_ami.coreos -auto-approve

# Prepare user data as base64 content
ami_id=$(terraform output coreos_ami_id)
ignition_json_filename=$(terraform output ignition_json_filename)
ignition_json_base64_filename="$ignition_json_filename.base64"
base64 $ignition_json_filename >$ignition_json_base64_filename

# Stop instances, update user data, restart instances
aws ec2 describe-instances --filters "Name=image-id, Values=$ami_id" --filters "Name=instance-state-name, Values=running" | jq -r '.Reservations[].Instances[].InstanceId' | while read instance_id; do
  echo "Updating instance $instance_id"

  aws ec2 stop-instances --instance-ids $instance_id
  aws ec2 wait instance-stopped --instance-ids $instance_id

  aws ec2 modify-instance-attribute --instance-id $instance_id --attribute userData --value file://$ignition_json_base64_filename
  
  aws ec2 start-instances --instance-ids $instance_id
  aws ec2 wait instance-running --instance-ids $instance_id
done

# Refresh terraform state
# It is required because an instance restart changes its network informations
terraform refresh

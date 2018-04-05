#!/bin/bash

exec aws ec2 describe-instances  | jq -r '.Reservations[].Instances[].NetworkInterfaces[].PrivateIpAddresses[].Association.PublicDnsName'

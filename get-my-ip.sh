#!/bin/bash

set -e

my_ip=$(curl -s -f https://httpbin.org/ip | jq -r .origin)

cat >my-ip.auto.tfvars <<EOF
my_ip = "$my_ip"
EOF

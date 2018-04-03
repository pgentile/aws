#!/bin/bash

set -e

cluster_size=1
token=$(curl -s -f "https://discovery.etcd.io/new?size=$cluster_size")

cat >etcd-discovery-token.auto.tfvars <<EOF
etcd_discovery_token = "$token"
EOF

echo "Discovery token: $token"

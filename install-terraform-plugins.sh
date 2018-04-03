#!/bin/bash

set -e 

plugins_dir="$HOME/.terraform.d/plugins/darwin_amd64"
version="v0.2.1"

mkdir -p $plugins_dir

cd $plugins_dir
curl -L -O "https://github.com/coreos/terraform-provider-ct/releases/download/$version/terraform-provider-ct-$version-darwin-amd64.tar.gz"

tar xzvf terraform-provider-ct-$version-darwin-amd64.tar.gz
rm terraform-provider-ct-$version-darwin-amd64.tar.gz

mv terraform-provider-ct-$version-darwin-amd64/terraform-provider-ct ./
rmdir terraform-provider-ct-$version-darwin-amd64

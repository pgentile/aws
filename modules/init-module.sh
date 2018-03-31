#!/bin/bash

set -e

dir="$1"

mkdir -p "$dir"
touch "$dir/variables.tf" "$dir/outputs.tf" "$dir/main.tf"

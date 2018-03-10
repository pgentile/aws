#!/bin/bash

set -e

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

command="$1"
shift

extras=
case "$command" in
    plan | apply | destroy | taint)
        extras="-var-file=$script_dir/my-ip.tfvars"
        ;;
esac

exec terraform "$command" $extras "$@"

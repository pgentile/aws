#!/bin/bash

set -e

command="$1"
shift

extras=
case "$command" in
    apply | destroy | taint)
        extras="-var-file=my-ip.tfvars"
        ;;
esac

exec terraform "$command" $extras "$@"

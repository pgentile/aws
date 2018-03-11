#!/bin/bash

set -e

yum -y erase ntp*
yum -y install chrony
service chronyd start
chkconfig chronyd on

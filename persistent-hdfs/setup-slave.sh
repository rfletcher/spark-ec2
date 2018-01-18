#!/bin/bash

set -e
set -x

# Setup persistent-hdfs
mkdir -p /spark-work/persistent-hdfs/logs

mkdir -p /var/hadoop
sudo chown hadoop:hadoop /var/hadoop

if [[ -e /vol/persistent-hdfs ]] ; then
  sudo chmod -R 755 /vol/persistent-hdfs
fi

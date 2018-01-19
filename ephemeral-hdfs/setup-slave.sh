#!/bin/bash

set -e
set -x

sudo adduser --disabled-login --gecos "" hadoop || true

# Setup ephemeral-hdfs
mkdir -p /spark-work/ephemeral-hdfs/logs
mkdir -p /spark-work/hadoop-logs

# Setup yarn logs, local dirs
mkdir -p /spark-work/yarn-local
mkdir -p /spark-work/yarn-logs

sudo mkdir -p /var/hadoop
sudo chown spark:spark /var/hadoop

# Create Hadoop and HDFS directories in a given parent directory
# (for example /spark-work, /spark-work2, and so on)
function create_hadoop_dirs {
  location=$1
  if [[ -e $location ]]; then
    sudo mkdir -p $location/ephemeral-hdfs $location/hadoop/tmp
    sudo chmod -R 755 $location/ephemeral-hdfs
    sudo mkdir -p $location/hadoop/mrlocal $location/hadoop/mrlocal2
  fi
}

# Set up Hadoop and Mesos directories in /spark-work
create_hadoop_dirs /spark-work
create_hadoop_dirs /spark-work2
create_hadoop_dirs /spark-work3
create_hadoop_dirs /spark-work4

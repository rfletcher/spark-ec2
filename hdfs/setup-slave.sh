#!/bin/bash

set -e
# set-x

# TODO move more of this to puppet?

sudo adduser --disabled-login --gecos "" hadoop || true

sudo mkdir -p /var/hadoop
sudo chown spark:spark /var/hadoop

# Create Hadoop and HDFS directories in a given parent directory
# (for example /spark-work, /spark-work2, and so on)
function create_work_dirs {
  BASE=$1

  if [[ -e $location ]]; then
    for DIR in \
      hdfs/{logs,} \
      hadoop/{logs,mrlocal,mrlocal2,tmp,} \
      yarn/{local,logs,}
    do
      DIR="${BASE}/${DIR}"

      sudo mkdir -p "$DIR"
      sudo chown spark:spark "$DIR"
    done
  fi
}

# Set up Hadoop and Mesos directories in /spark-work
create_work_dirs /spark-work
create_work_dirs /spark-work2
create_work_dirs /spark-work3
create_work_dirs /spark-work4

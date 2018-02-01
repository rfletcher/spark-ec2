#!/bin/bash

set -e
# set-x

MAPREDUCE=/spark-home/mapreduce

mkdir -p /spark-work/mapreduce/logs
for node in $SLAVES $OTHER_MASTERS; do
  ssh -t $SSH_OPTS $node -- <<-EOT
    mkdir -p /spark-work/mapreduce/logs &&
    sudo chown hadoop:hadoop /spark-work/mapreduce/logs &&
    sudo chown hadoop:hadoop /spark-work/mapreduce
	EOT
  # sleep 0.3
done
wait

sudo chown hadoop:hadoop /spark-work/mapreduce -R

/spark-home/spark-ec2/copy-dir $MAPREDUCE/conf

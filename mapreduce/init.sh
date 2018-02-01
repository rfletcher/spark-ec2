#!/bin/bash

set -e
# set-x

pushd /spark-home/spark-ec2/mapreduce > /dev/null

# point mapreduce/ to the right version locally...
source set-version.sh

parallel-ssh --inline \
  --hosts "/spark-home/spark-ec2/slaves" \
  --user spark \
  --extra-args "-t -t $SSH_OPTS" \
  --timeout 0 \
  "/spark-home/spark-ec2/mapreduce/set-version.sh $HADOOP_MAJOR_VERSION"

popd >/dev/null


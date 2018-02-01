#!/bin/bash

set -e
set -x

pushd /spark-home/spark-ec2/ephemeral-hdfs > /dev/null

# point ephemeral-hdfs/ to the right version locally...
source set-version.sh

# ...and on other instances
parallel-ssh --inline \
  --hosts "/spark-home/spark-ec2/slaves" \
  --user spark \
  --extra-args "-t -t $SSH_OPTS" \
  --timeout 0 \
  "/spark-home/spark-ec2/ephemeral-hdfs/set-version.sh $HADOOP_MAJOR_VERSION"

popd >/dev/null

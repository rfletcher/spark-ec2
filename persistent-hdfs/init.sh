#!/bin/bash

set -e
set -x

pushd /spark-home/spark-ec2/persistent-hdfs > /dev/null

# point ephemeral-hdfs/ to the right version locally...
source set-version.sh

# ...and on other instances
for node in $SLAVES $OTHER_MASTERS; do
  ssh -t $SSH_OPTS $node "/spark-home/spark-ec2/persistent-hdfs/set-version.sh $HADOOP_MAJOR_VERSION" & sleep 0.3
done
wait

popd >/dev/null

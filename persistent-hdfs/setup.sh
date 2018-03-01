#!/bin/bash

set -e
# set-x

PERSISTENT_HDFS=/spark-home/persistent-hdfs

pushd /spark-home/spark-ec2/persistent-hdfs > /dev/null
source ./setup-slave.sh

for node in $SLAVES $OTHER_MASTERS; do
  ssh -t $SSH_OPTS $node "/spark-home/spark-ec2/persistent-hdfs/setup-slave.sh" & sleep 0.3
done
wait

/spark-home/spark-ec2/copy-dir --delete $PERSISTENT_HDFS/conf

if [[ ! -e /vol/persistent-hdfs/dfs/name ]] ; then
  echo "Formatting persistent HDFS namenode..."
  $PERSISTENT_HDFS/bin/hadoop namenode -format -force
fi

echo "Persistent HDFS installed, won't start by default..."

popd > /dev/null

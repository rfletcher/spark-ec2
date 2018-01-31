#!/bin/bash

set -e
set -x

pushd /spark-home/spark-ec2/spark > /dev/null

# point spark/ to the right version locally...
source set-version.sh

# ...and on other instances
for node in $SLAVES $OTHER_MASTERS; do
  ssh -t $SSH_OPTS $node "/spark-home/spark-ec2/spark/set-version.sh $SPARK_VERSION" & sleep 0.3
done
wait

popd >/dev/null

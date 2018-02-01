#!/bin/bash

set -e
# set-x

pushd /spark-home/spark-ec2/spark > /dev/null

# point spark/ to the right version locally...
source set-version.sh

# ...and on other instances
parallel-ssh --inline \
  --hosts "/spark-home/spark-ec2/slaves" \
  --user spark \
  --extra-args "-t -t $SSH_OPTS" \
  --timeout 0 \
  "/spark-home/spark-ec2/spark/set-version.sh $SPARK_VERSION"

popd >/dev/null

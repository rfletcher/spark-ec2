#!/bin/bash

set -e
# set-x

HDFS=/spark-home/hdfs

# Set hdfs url to make it easier
HDFS_URL="hdfs://$PUBLIC_DNS:9000"
echo "export HDFS_URL=$HDFS_URL" >> ~/.bash_profile

pushd /spark-home/spark-ec2/hdfs > /dev/null
source ./setup-slave.sh

for node in $SLAVES $OTHER_MASTERS; do
  echo $node
  ssh -t -t $SSH_OPTS $node "/spark-home/spark-ec2/hdfs/setup-slave.sh" & sleep 0.3
done
wait

/spark-home/spark-ec2/copy-dir --delete $HDFS/conf

NAMENODE_DIR=/spark-work/hdfs/dfs/name

if [ -f "$NAMENODE_DIR/current/VERSION" ] && [ -f "$NAMENODE_DIR/current/fsimage" ]; then
  echo "Hadoop namenode appears to be formatted: skipping"
else
  echo "Formatting ephemeral HDFS namenode..."
  export NAMENODE_DIR
  $HDFS/bin/hadoop namenode -format -force
fi

echo "Starting ephemeral HDFS..."

# This is different depending on version.
case "$HADOOP_MAJOR_VERSION" in
  2)
    $HDFS/sbin/start-dfs.sh
    ;;
  yarn) 
    $HDFS/sbin/start-dfs.sh
    echo "Starting YARN"
    $HDFS/sbin/start-yarn.sh
    ;;
  *)
     echo "ERROR: Unknown Hadoop version"
     return -1
esac

popd > /dev/null

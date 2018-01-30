#!/bin/bash

set -e
set -x

pushd /spark-home > /dev/null

if [ -d "persistent-hdfs" ]; then
  echo "Persistent HDFS seems to be installed. Exiting."
  return 0
fi

DEBIAN_FRONTEND=noninteractive sudo apt-get install \
  --assume-yes --allow-downgrades --allow-remove-essential --allow-change-held-packages \
  libsnappy1v5

case "$HADOOP_MAJOR_VERSION" in
  2)
    wget http://archive.apache.org/dist/hadoop/common/hadoop-2.4.1/hadoop-2.4.1.tar.gz
    wget http://s3.amazonaws.com/spark-related-packages/hadoop-2.0.0-cdh4.2.0.tar.gz
    echo "Unpacking Hadoop"
    tar xvzf hadoop-2.4.1.tar.gz > /tmp/spark-ec2_hadoop.log
    tar xvzf hadoop-2.0.0-cdh4.2.0.tar.gz >> /tmp/spark-ec2_hadoop.log
    rm hadoop-*.tar.gz
    mv hadoop-2.0.0-cdh4.2.0/ persistent-hdfs/

    # Have single conf dir
    rm -rf /spark-home/persistent-hdfs/etc/hadoop/
    ln -s /spark-home/persistent-hdfs/conf /spark-home/persistent-hdfs/etc/hadoop
    cp hadoop-2.4.1/lib/native/* /spark-home/persistent-hdfs/lib/native/
    ln -sf /usr/lib/x86_64-linux-gnu/libsnappy.so.1 /spark-home/persistent-hdfs/lib/native/.
    ;;
  yarn)
    wget http://s3.amazonaws.com/spark-related-packages/hadoop-2.4.0.tar.gz
    echo "Unpacking Hadoop"
    tar xvzf hadoop-*.tar.gz > /tmp/spark-ec2_hadoop.log
    rm hadoop-*.tar.gz
    mv hadoop-2.4.0/ persistent-hdfs/

    # Have single conf dir
    rm -rf /spark-home/persistent-hdfs/etc/hadoop/
    ln -s /spark-home/persistent-hdfs/conf /spark-home/persistent-hdfs/etc/hadoop
    ;;

  *)
     echo "ERROR: Unknown Hadoop version"
     return 1
esac

/spark-home/spark-ec2/copy-dir /spark-home/persistent-hdfs

popd > /dev/null

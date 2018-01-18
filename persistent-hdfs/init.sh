#!/bin/bash

pushd /spark > /dev/null

if [ -d "persistent-hdfs" ]; then
  echo "Persistent HDFS seems to be installed. Exiting."
  return 0
fi

case "$HADOOP_MAJOR_VERSION" in
  1)
    wget http://s3.amazonaws.com/spark-related-packages/hadoop-1.0.4.tar.gz
    echo "Unpacking Hadoop"
    tar xvzf hadoop-1.0.4.tar.gz > /tmp/spark-ec2_hadoop.log
    rm hadoop-*.tar.gz
    mv hadoop-1.0.4/ persistent-hdfs/
    cp /spark/hadoop-native/* /spark/persistent-hdfs/lib/native/
    ;;
  2)
    wget http://s3.amazonaws.com/spark-related-packages/hadoop-2.0.0-cdh4.2.0.tar.gz
    echo "Unpacking Hadoop"
    tar xvzf hadoop-*.tar.gz > /tmp/spark-ec2_hadoop.log
    rm hadoop-*.tar.gz
    mv hadoop-2.0.0-cdh4.2.0/ persistent-hdfs/

    # Have single conf dir
    rm -rf /spark/persistent-hdfs/etc/hadoop/
    ln -s /spark/persistent-hdfs/conf /spark/persistent-hdfs/etc/hadoop
    cp /spark/hadoop-native/* /spark/persistent-hdfs/lib/native/
    ;;
  yarn)
    wget http://s3.amazonaws.com/spark-related-packages/hadoop-2.4.0.tar.gz
    echo "Unpacking Hadoop"
    tar xvzf hadoop-*.tar.gz > /tmp/spark-ec2_hadoop.log
    rm hadoop-*.tar.gz
    mv hadoop-2.4.0/ persistent-hdfs/

    # Have single conf dir
    rm -rf /spark/persistent-hdfs/etc/hadoop/
    ln -s /spark/persistent-hdfs/conf /spark/persistent-hdfs/etc/hadoop
    ;;

  *)
     echo "ERROR: Unknown Hadoop version"
     return 1
esac
/spark/spark-ec2/copy-dir /spark/persistent-hdfs

popd > /dev/null

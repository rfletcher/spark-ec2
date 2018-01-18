#!/bin/bash

pushd /spark-home > /dev/null
case "$HADOOP_MAJOR_VERSION" in
  1)
    echo "Nothing to initialize for MapReduce in Hadoop 1"
    ;;
  2) 
    wget http://s3.amazonaws.com/spark-related-packages/mr1-2.0.0-mr1-cdh4.2.0.tar.gz 
    tar -xvzf mr1-*.tar.gz > /tmp/spark-ec2_mapreduce.log
    rm mr1-*.tar.gz
    mv hadoop-2.0.0-mr1-cdh4.2.0/ mapreduce/
    ;;
  yarn)
    echo "Nothing to initialize for MapReduce in Hadoop 2 YARN"
    ;;

  *)
     echo "ERROR: Unknown Hadoop version"
     return -1
esac
/spark-home/spark-ec2/copy-dir /spark-home/mapreduce
popd > /dev/null

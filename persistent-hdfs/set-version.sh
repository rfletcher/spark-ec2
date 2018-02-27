#!/bin/bash

set -e
# set-x

if [[ "$HADOOP_MAJOR_VERSION" == "" ]]; then
  HADOOP_MAJOR_VERSION="$1"
fi

pushd /spark-home > /dev/null

case "$HADOOP_MAJOR_VERSION" in
  2)    HADOOP_VERSION="2.0.0";;
  yarn) HADOOP_VERSION="2.7.3";;
  *)    echo "ERROR: Unknown Hadoop version"; return 1;;
esac

if [[ ! -d "hadoop-${HADOOP_VERSION}" ]]; then
  echo "ERROR: Hadoop ${HADOOP_VERSION} is not available"
  return -1
fi

ln -fs "hadoop-${HADOOP_VERSION}" persistent-hdfs

popd > /dev/null

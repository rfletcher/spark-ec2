#!/bin/bash

set -e
# set-x

if [[ "$HADOOP_MAJOR_VERSION" == "" ]]; then
  HADOOP_MAJOR_VERSION="$1"
fi

pushd /spark-home > /dev/null

case "$HADOOP_MAJOR_VERSION" in
  2)    MAPREDUCE_VERSION="2.0.0";;
  yarn) MAPREDUCE_VERSION="stub";;
  *)    echo "ERROR: Unknown Hadoop version"; return 1;;
esac

if [[ ! -d "mapreduce-${MAPREDUCE_VERSION}" ]]; then
  echo "ERROR: Mapreduce ${MAPREDUCE_VERSION} is not available"
  return -1
fi

ln -fs "mapreduce-${MAPREDUCE_VERSION}" mapreduce

popd > /dev/null

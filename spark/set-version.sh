#!/bin/bash

set -e
# set-x

if [[ "$SPARK_VERSION" == "" ]]; then
  SPARK_VERSION="$1"
fi

pushd /spark-home > /dev/null

if [[ ! -d "spark-${SPARK_VERSION}" ]]; then
  echo "ERROR: Spark ${SPARK_VERSION} is not available"
  return -1
fi

ln -fs "spark-${SPARK_VERSION}" spark

popd > /dev/null

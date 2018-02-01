#!/bin/bash

set -e
# set-x

BIN_FOLDER="/spark-home/spark/sbin"

if [[ "0.7.3 0.8.0 0.8.1" =~ $SPARK_VERSION ]]; then
  BIN_FOLDER="/spark-home/spark/bin"
fi

# Copy the slaves to spark conf
cp /spark-home/spark-ec2/slaves /spark-home/spark/conf/
/spark-home/spark-ec2/copy-dir /spark-home/spark/conf

# Set cluster-url to standalone master
echo "spark://""`cat /spark-home/spark-ec2/masters`"":7077" > /spark-home/spark-ec2/cluster-url
/spark-home/spark-ec2/copy-dir /spark-home/spark-ec2

# The Spark master seems to take time to start and workers crash if
# they start before the master. So start the master first, sleep and then start
# workers.

# Stop anything that is running
sudo $BIN_FOLDER/stop-all.sh

sleep 2

# Start Master
sudo $BIN_FOLDER/start-master.sh

# Pause
sleep 20

# Start Workers
sudo $BIN_FOLDER/start-slaves.sh

#!/bin/bash

/spark-home/spark-ec2/copy-dir /spark-home/tachyon

/spark-home/tachyon/bin/tachyon format

sleep 1

/spark-home/tachyon/bin/tachyon-start.sh all Mount

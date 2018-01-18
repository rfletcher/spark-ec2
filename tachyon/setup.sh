#!/bin/bash

set -e
set -x

/spark-home/spark-ec2/copy-dir /spark-home/tachyon

sudo /spark-home/tachyon/bin/tachyon format

sleep 1

sudo /spark-home/tachyon/bin/tachyon-start.sh all Mount

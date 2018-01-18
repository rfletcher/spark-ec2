#!/bin/bash

/spark/spark-ec2/copy-dir /spark/tachyon

/spark/tachyon/bin/tachyon format

sleep 1

/spark/tachyon/bin/tachyon-start.sh all Mount

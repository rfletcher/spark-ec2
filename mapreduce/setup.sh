#!/bin/bash
MAPREDUCE=/spark-home/mapreduce

mkdir -p /spark/mapreduce/logs
for node in $SLAVES $OTHER_MASTERS; do
  ssh -t $SSH_OPTS root@$node "mkdir -p /spark/mapreduce/logs && chown hadoop:hadoop /spark/mapreduce/logs && chown hadoop:hadoop /spark/mapreduce" & sleep 0.3
done
wait

chown hadoop:hadoop /spark/mapreduce -R
/spark-home/spark-ec2/copy-dir $MAPREDUCE/conf

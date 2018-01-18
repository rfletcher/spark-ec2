#!/bin/bash

set -e
set -x

sudo DEBIAN_FRONTEND=noninteractive apt-get install \
  --assume-yes --allow-downgrades --allow-remove-essential --allow-change-held-packages \
  default-jre-headless

echo 'export JAVA_HOME=/usr/lib/jvm/default-java' >> /spark-home/.bash_profile

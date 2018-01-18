#!/bin/bash

set -e
set -x

if [ $# -lt 1 ]; then
  echo "Usage: create-swap.sh <amount of MB>"
  exit 1
fi

if [ -e /spark-work/swap ]; then
  echo "/spark-work/swap already exists" >&2
  exit 1
fi

SWAP_MB=$1
if [[ "$SWAP_MB" != "0" ]]; then
  dd if=/dev/zero of=/spark-work/swap bs=1M count=$SWAP_MB
  mkswap /spark-work/swap
  swapon /spark-work/swap
  echo "Added $SWAP_MB MB swap file /spark-work/swap"
fi

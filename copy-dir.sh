#!/bin/bash

set -e
# set-x

DELETE_FLAG=""

usage() {
  echo "Usage: copy-dir [--delete] <dir>"
  exit 1
}

while :
do
  case $1 in
    --delete)
      DELETE_FLAG="--delete"
      shift
      ;;
    -*)
      echo "ERROR: Unknown option: $1" >&2
      usage
      ;;
    *) # End of options
      break
      ;;
  esac
done

if [[ "$#" != "1" ]] ; then
  usage
fi

if [[ ! -e "$1" ]] ; then
  echo "File or directory $1 doesn't exist!"
  exit 1
fi

DIR=`readlink -f "$1"`
DIR=`echo "$DIR"|sed 's@/$@@'`
DEST=`dirname "$DIR"`

SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5"

echo "RSYNC'ing $DIR to slaves..."

parallel-rsync --hosts "/spark-home/spark-ec2/slaves" \
  --ssh-args "$SSH_OPTS" \
  --extra-args "-aKklz $DELET_FLAG" \
  "$DIR" "$DEST"

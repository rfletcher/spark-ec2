#!/bin/bash

set -e
# set-x

## master setup

# usage: echo_time_diff name start_time end_time
echo_time_diff () {
  local format='%Hh %Mm %Ss'

  local diff_secs="$(($3-$2))"
  echo "[timing] $1: " "$(date -u -d@"$diff_secs" +"$format")"
}

# Make sure we are in the spark-ec2 directory
pushd /spark-home/spark-ec2 > /dev/null

# Load the environment variables specific to this AMI
source /spark-home/.bash_profile

# Load the cluster variables set by the deploy script
source ec2-variables.sh

# Set hostname based on EC2 private DNS name, so that it is set correctly
# even if the instance is restarted with a different private DNS name
PRIVATE_DNS=`wget -q -O - http://169.254.169.254/latest/meta-data/local-hostname`
PUBLIC_DNS=`wget -q -O - http://169.254.169.254/latest/meta-data/hostname`
sudo hostname $PRIVATE_DNS
echo $PRIVATE_DNS | sudo tee /etc/hostname
export HOSTNAME=$PRIVATE_DNS  # Fix the bash built-in hostname variable too

echo "Setting up Spark on `hostname`..."

# Set up the masters, slaves, etc files based on cluster env variables
echo "$MASTERS" > masters
echo "$SLAVES" > slaves

MASTERS=`cat masters`
NUM_MASTERS=`cat masters | wc -l`
OTHER_MASTERS=`cat masters | sed '1d'`
SLAVES=`cat slaves`
SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5"

if [[ "x$JAVA_HOME" == "x" ]] ; then
    echo "Expected JAVA_HOME to be set in .bash_profile!"
    exit 1
fi

if [[ `tty` == "not a tty" ]] ; then
    echo "Expecting a tty or pty! (use the ssh -t option)."
    exit 1
fi

echo "Setting executable permissions on scripts..."
find . -regex "^.+.\(sh\|py\)" | xargs chmod a+x

echo "Syncing /spark-home/spark-ec2 to other cluster nodes..."
rsync_start_time="$(date +'%s')"
parallel-rsync --hosts ./slaves \
  --ssh-args "$SSH_OPTS" \
  --extra-args "-aKklz" \
  /spark-home/spark-ec2/ /spark-home/spark-ec2/
rsync_end_time="$(date +'%s')"
echo_time_diff "rsync /spark-home/spark-ec2" "$rsync_start_time" "$rsync_end_time"

echo "Running setup-slave on all cluster nodes to mount filesystems, etc..."
setup_slave_start_time="$(date +'%s')"
parallel-ssh --inline \
    --host "$MASTERS $SLAVES" \
    --user spark \
    --extra-args "-t -t $SSH_OPTS" \
    --timeout 0 \
    "sudo spark-ec2/setup-slave.sh"
setup_slave_end_time="$(date +'%s')"
echo_time_diff "setup-slave" "$setup_slave_start_time" "$setup_slave_end_time"

# Install / Init module
for module in $MODULES; do
  echo "Initializing $module"
  module_init_start_time="$(date +'%s')"
  if [[ -e $module/init.sh ]]; then
    source $module/init.sh
  fi
  module_init_end_time="$(date +'%s')"
  echo_time_diff "$module init" "$module_init_start_time" "$module_init_end_time"
  cd /spark-home/spark-ec2  # guard against init.sh changing the cwd
done

# Deploy templates
# TODO: Move configuring templates to a per-module ?
echo "Creating local config files..."
./deploy_templates.py

# Copy spark conf by default
echo "Deploying Spark config files..."
chmod u+x /spark-home/spark/conf/spark-env.sh
/spark-home/spark-ec2/copy-dir /spark-home/spark/conf

# Setup each module
for module in $MODULES; do
  if [[ -e ./$module/setup.sh ]]; then
    echo "Setting up $module"
    module_setup_start_time="$(date +'%s')"
    source ./$module/setup.sh
    sleep 0.1
    module_setup_end_time="$(date +'%s')"
    echo_time_diff "$module setup" "$module_setup_start_time" "$module_setup_end_time"
  fi
  cd /spark-home/spark-ec2  # guard against setup.sh changing the cwd
done

popd > /dev/null

#!/bin/bash

set -e
# set-x

# Disable Transparent Huge Pages (THP)
# THP can result in system thrashing (high sys usage) due to frequent defrags of memory.
# Most systems recommends turning THP off.
if [[ -e /sys/kernel/mm/transparent_hugepage/enabled ]]; then
  echo never > /sys/kernel/mm/transparent_hugepage/enabled
fi

# Make sure we are in the spark-ec2 directory
pushd /spark-home/spark-ec2 > /dev/null

source /spark-home/.bash_profile
source ec2-variables.sh

# Set hostname based on EC2 private DNS name, so that it is set correctly
# even if the instance is restarted with a different private DNS name
PRIVATE_DNS=`wget -q -O - http://169.254.169.254/latest/meta-data/local-hostname`
hostname $PRIVATE_DNS
echo $PRIVATE_DNS > /etc/hostname
HOSTNAME=$PRIVATE_DNS  # Fix the bash built-in hostname variable too

echo "checking/fixing resolution of hostname"
bash /spark-home/spark-ec2/resolve-hostname.sh

# Work around for R3 or I2 instances without pre-formatted ext3 disks
instance_type=$(curl http://169.254.169.254/latest/meta-data/instance-type 2> /dev/null)

echo "Setting up slave on `hostname`... of type $instance_type"

if [[ $instance_type == r3* || $instance_type == m3* || $instance_type == i2* || $instance_type == hi1* ]]; then
  # Format & mount using ext4, which has the best performance among ext3, ext4, and xfs based
  # on our shuffle heavy benchmark
  EXT4_MOUNT_OPTS="defaults,noatime"
  rm -rf /spark-work*
  mkdir /spark-work
  # To turn TRIM support on, uncomment the following line.
  #echo '/dev/xvdb /spark-work  ext4  defaults,noatime,discard 0 0' >> /etc/fstab
  mkfs.ext4 -FE lazy_itable_init=0,lazy_journal_init=0 /dev/xvdb
  mount -o $EXT4_MOUNT_OPTS /dev/xvdb /spark-work

  if [[ $instance_type == "r3.8xlarge" || $instance_type == "hi1.4xlarge" ]]; then
    mkdir /spark-work2
    # To turn TRIM support on, uncomment the following line.
    #echo '/dev/xvdc /spark-work2  ext4  defaults,noatime,discard 0 0' >> /etc/fstab
    if [[ $instance_type == "r3.8xlarge" ]]; then
      mkfs.ext4 -FE lazy_itable_init=0,lazy_journal_init=0 /dev/xvdc
      mount -o $EXT4_MOUNT_OPTS /dev/xvdc /spark-work2
    fi
    # To turn TRIM support on, uncomment the following line.
    #echo '/dev/xvdf /spark-work2  ext4  defaults,noatime,discard 0 0' >> /etc/fstab
    if [[ $instance_type == "hi1.4xlarge" ]]; then
      mkfs.ext4 -FE lazy_itable_init=0,lazy_journal_init=0 /dev/xvdf
      mount -o $EXT4_MOUNT_OPTS /dev/xvdf /spark-work2
    fi    
  fi
fi

mkdir /spark-work || true

# Mount options to use for ext3 and xfs disks (the ephemeral disks
# are ext3, but we use xfs for EBS volumes to format them faster)
XFS_MOUNT_OPTS="defaults,noatime,allocsize=8m"

function setup_ebs_volume {
  device=$1
  mount_point=$2
  if [[ -e $device ]]; then
    # Check if device is already formatted
    if ! blkid $device; then
      mkdir $mount_point
      if mkfs.xfs -q $device; then
        mount -o $XFS_MOUNT_OPTS $device $mount_point
        chmod -R a+w $mount_point
      else
        # mkfs.xfs is not installed on this machine or has failed;
        # delete /vol so that the user doesn't think we successfully
        # mounted the EBS volume
        rmdir $mount_point
      fi
    else
      # EBS volume is already formatted. Mount it if its not mounted yet.
      if ! grep -qs '$mount_point' /proc/mounts; then
        mkdir $mount_point
        mount -o $XFS_MOUNT_OPTS $device $mount_point
        chmod -R a+w $mount_point
      fi
    fi
  fi
}

# Format and mount EBS volume (/dev/xvd[s, t, u, v, w, x, y, z]) as /vol[x] if the device exists
setup_ebs_volume /dev/xvds /vol0
setup_ebs_volume /dev/xvdt /vol1
setup_ebs_volume /dev/xvdu /vol2
setup_ebs_volume /dev/xvdv /vol3
setup_ebs_volume /dev/xvdw /vol4
setup_ebs_volume /dev/xvdx /vol5
setup_ebs_volume /dev/xvdy /vol6
setup_ebs_volume /dev/xvdz /vol7

# Alias vol to vol3 for backward compatibility: the old spark-ec2 script supports only attaching
# one EBS volume at /dev/xvdv.
if [[ -e /vol3 && ! -e /vol ]]; then
  ln -s /vol3 /vol
fi

# Make data dirs writable by non-root users, such as CDH's hadoop user
chmod a+x /spark-home
chmod -R a+w /spark-work*

# Remove ~/.ssh/known_hosts because it gets polluted as you start/stop many
# clusters (new machines tend to come up under old hostnames)
rm -f /spark-home/.ssh/known_hosts

# Allow memory to be over committed. Helps in pyspark where we fork
echo 1 > /proc/sys/vm/overcommit_memory

# Add github to known hosts to get git@github.com clone to work
# TODO(shivaram): Avoid duplicate entries ?
cat /spark-home/spark-ec2/github.hostkey >> /spark-home/.ssh/known_hosts

# Create /usr/bin/realpath which is used by R to find Java installations
# NOTE: /usr/bin/realpath is missing in CentOS AMIs. See
# http://superuser.com/questions/771104/usr-bin-realpath-not-found-in-centos-6-5
echo '#!/bin/bash' > /usr/bin/realpath
echo 'readlink -e "$@"' >> /usr/bin/realpath
chmod a+x /usr/bin/realpath

popd > /dev/null

# this is to set the ulimit for root and other users
echo '* soft nofile 1000000' >> /etc/security/limits.conf
echo '* hard nofile 1000000' >> /etc/security/limits.conf

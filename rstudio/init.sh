#!/usr/bin/env bash

set -e
set -x

if ! sudo service rstudio-server status; then
  # download rstudio 
  DEBIAN_FRONTEND=noninteractive sudo apt-get install \
    --assume-yes --allow-downgrades --allow-remove-essential --allow-change-held-packages \
    r-base

  wget http://download2.rstudio.org/rstudio-server-0.99.441-amd64.deb
  sudo dpkg -i rstudio-server-0.99.441-amd64.deb
fi

# restart rstudio 
sudo service rstudio-server restart

# add user for rstudio, user needs to supply password later on
sudo adduser --disabled-login --gecos "" rstudio || true

# create a Rscript that connects to Spark, to help starting user
sudo cp /spark-home/spark-ec2/rstudio/startSpark.R /home/rstudio

# make sure that the temp dirs exist and can be written to by any user
# otherwise this will create a conflict for the rstudio user
function create_temp_dirs {
  location=$1
  if [[ ! -e $location ]]; then
    sudo mkdir -p $location
  fi
  sudo chmod a+w $location
}

create_temp_dirs /spark-work/spark
create_temp_dirs /spark-work2/spark
create_temp_dirs /spark-work3/spark
create_temp_dirs /spark-work4/spark

#!/bin/sh
#
# Start-up script for ipyparallel controller node
#
# Copyright (C) 2023 Simon Dobson
#
# This file is part of cloud-epydemic, network simulation as a service
#
# cloud-epydemic is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published byf
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# cloud-epydemic is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with cloud-epydemic. If not, see <http://www.gnu.org/licenses/gpl.html>.

# We expect one environment variable to be defined by the container:
#
# - EPYDEMIC_PROFILE -- the IPython profile for the cluster
#
# This is used to compute EPYDEMIC_PROFILE_DIR where the IPython profile
# lives. This directory will usually be on a volume so that it's shared
# between all the containers in a cluster. This makes parallelism easier
# to manage by sharing the config files, rather than explicitly passing
# around capabilities.
#
# We also accept a single run-time variable:
#
# - EPYDEMIC_CONTROLLER_HOST -- the name or IP address of the machine
#                               running the controller (defaults to
#                               the result of running hostname)

# Create an ssh keypair for tunneling
ssh-keygen -t rsa -N '' -f .ssh/id_rsa
cat .ssh/id_rsa.pub >>.ssh/authorized_keys
ssh-keyscan -t rsa $EPYDEMIC_CONTROLLER_HOST >>.ssh/known_hosts

# Create the profile
ipython profile create --parallel $EPYDEMIC_PROFILE
EPYDEMIC_PROFILE_DIR=`ipython profile locate $EPYDEMIC_PROFILE`
EPYDEMIC_CONTROLLER_FILE="$EPYDEMIC_PROFILE_DIR/ipcontroller_config.py"
cat >>$EPYDEMIC_CONTROLLER_FILE <<EOF
# Listen on all interfaces
c.IPController.ip = ''

# ssh-based cluster, without secure authentication or encryption (we assume
# we're running on a secure network)
c.IPClusterEngines.engine_launcher_class = 'SSHEngineSetLauncher'
c.IPController.enable_curve = False
c.SSHLauncher.to_send = []
c.SSHLauncher.to_fetch = []

# Persistent store for jobs
c.IPController.db_class = 'SQLiteDB'
EOF

# Locate the controller
HOST=`hostname`
CONTROLLER_HOST=${EPYDEMIC_CONTROLLER_HOST:-$HOST}

# Start the controller
ipcontroller --ip='*' --profile=$EPYDEMIC_PROFILE --ssh=$CONTROLLER_HOST

#!/bin/sh
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

# We expect three environment variables to be defined by the container:
#
# - EPYDEMIC_PROFILE -- the IPython profile for the cluster
# - EPYDEMIC_PROFILE_DIR -- the directory containing this profile
# - EPYDEMIC_WORKING_DIR -- the working directory for shared storage
#
# We also accept a single run-time variable:
#
# - EPYDEMIC_CONTROLLER_HOST -- the name or IP address of the machine
#                               running the controller (defaults to
#                               the result of running hostname)

# Locate the ACLs
CONTROLLER_ACL="$EPYDEMIC_PROFILE_DIR/security/ipcontroller-client.json"
ENGINE_ACL="$EPYDEMIC_PROFILE_DIR/security/ipcontroller-engine.json"

# Locate the controller
HOST=`hostname`
CONTROLLER_HOST=${EPYDEMIC_CONTROLLER_HOST:-$HOST}

# Start the controller
nohup ipcontroller --ip=0.0.0.0 --profile=$EPYDEMIC_PROFILE --ssh=$CONTROLLER_HOST &

# Publish the ACLs
cp $CONTROLLER_ACL $EPYDEMIC_WORKING_DIR
cp $ENGINE_ACL $EPYDEMIC_WORKING_DIR

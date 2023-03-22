#!/bin/bash
#
# Script to start and stop a containeriesed installation for testing
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

# Containers etc
REPO_USER=simoninireland
NETWORK=cloudepydemic
ENGINE=$REPO_USER/micro-engine
SHIM=$REPO_USER/micro-engine-rabbitmq-shim
BROKER=rabbitmq

# Environments
SHIM_ENV="-e EPYDEMIC_ENGINE_HOST=engine \
	  -e RABBITMQ_HOST=broker \
	  -e RABBITMQ_REQUEST_CHANNEL=request \
	  -e RABBITMQ_RESULT_CHANNEL=result"

# Pid file
PIDS=containers.pids

# Switch on first argument
command=$1
if [ "$command" == "start" ]; then
    if [ -e $PIDS ]; then
	# stop the previous containers
	echo "Forcing stop of previous containers"
	$0 stop
    fi

    # create a network for the containers to share
    docker network create $NETWORK

    # start the micro-engine service
    echo `docker run --rm -it -d -p 5000:5000 --name engine $ENGINE` >>$PIDS

    # start the broker
    echo `docker run --rm -it -d -p 15672:15672 -p 5672:5672 --name broker $BROKER` >>$PIDS

    # start the shim
    echo `docker run --rm -it -d -p 6000:5672 $SHIM_ENV --name shim $SHIM` >>$PIDS

    # place the containers on the network
    cat $PIDS | xargs -n 1 docker network connect $NETWORK
elif [ "$command" == "stop" ]; then
    # kill all the containers
    cat $PIDS | xargs docker container rm -f
    rm -fr $PIDS

    # kill the network
    docker network rm -f $NETWORK
else
    echo "Usage: containers.sh [start|stop]"
fi

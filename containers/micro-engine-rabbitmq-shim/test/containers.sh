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
GATEWAY=$REPO_USER/api-gateway

# Environments
ENV="-e EPYDEMIC_ENGINE_API_ENDPOINT=http://engine:5000/api/v1 \
     -e RABBITMQ_ENDPOINT=amqp://broker:5672 \
     -e RABBITMQ_REQUEST_QUEUE=request \
     -e RABBITMQ_RESULT_QUEUE=result"

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
    docker run --rm -it -d --network $NETWORK --name engine $ENGINE >>$PIDS

    # start the broker
    docker run --rm -it -d --network $NETWORK -p 5672:5672 --name broker $BROKER >>$PIDS

    # start the shim
    docker run --rm -it -d --network $NETWORK $ENV --name shim $SHIM >>$PIDS

    # start the gateway
    docker run --rm -it -d --network $NETWORK -p 5000:5000 $ENV --name gateway $GATEWAY >>$PIDS
elif [ "$command" == "stop" ]; then
    # kill all the containers
    if [ -e $PIDS ]; then
	cat $PIDS | xargs docker container rm -f
	rm -fr $PIDS
    fi

    # kill the network
    docker network rm -f $NETWORK
else
    echo "Usage: containers.sh [start|stop]"
fi

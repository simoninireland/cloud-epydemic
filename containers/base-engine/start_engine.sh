#!/bin/sh
#
# Start-up script for ipyparallel engine node
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
# We also accept an optional build-time variable:
#
# - EPYDEMIC_ENGINES -- the number of engines in the container
#
# This defaults to 1, and can be set to any value to deal with
# multicore systems.

# Compute the number of engines
ENGINES=${EPYDEMIC_ENGINES:-1}

# Start the engine
ipcluster engines --n=$ENGINES --profile=$EPYDEMIC_PROFILE

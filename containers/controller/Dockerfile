# Dockerfile to create a compute cluster controller
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

# Base image can be provided at build-time, and must use the same
# Python version across the cluster to avoid issues with code serialisation
ARG BASE_IMAGE="python:3.9"

# Base image
FROM $BASE_IMAGE
LABEL description="cloud-epydemic compute cluster controller"
LABEL maintainer="Simon Dobson <simon.dobson@st-andrews.ac.uk>"

# Build-time arguments to configure the cluster
ARG EPYDEMIC_USER="epydemic"
ARG EPYDEMIC_PROFILE="epydemic"
ARG EPYDEMIC_WORKING_DIR=/mnt/$EPYDEMIC_USER

# Install the HDF5 libraries needed by epyc and ipyparallel
USER root
RUN <<EOF
apt update
apt-get install -y hdf5-tools
apt-get install -y sqlite3
EOF

# Add a user
ENV EPYDEMIC_HOME="/home/$EPYDEMIC_USER"
RUN useradd -m -d $EPYDEMIC_HOME -s /bin/bash $EPYDEMIC_USER

# Install the additional Python dependencies
WORKDIR $EPYDEMIC_HOME
COPY ./requirements.txt .
RUN chown $EPYDEMIC_USER requirements.txt
RUN pip install --upgrade pip wheel
RUN pip install --no-cache-dir -r requirements.txt

# Install the controller script
COPY ./start_controller.sh .
RUN chown $EPYDEMIC_USER start_controller.sh
RUN chmod u+x start_controller.sh

# Create working storage, which will be treated as a mount point
ENV EPYDEMIC_WORKING_DIR=$EPYDEMIC_WORKING_DIR
RUN mkdir $EPYDEMIC_WORKING_DIR
RUN chown $EPYDEMIC_USER $EPYDEMIC_WORKING_DIR

# Switch to the non-root user
USER $EPYDEMIC_USER

# Set up the controller configuraiton
ENV EPYDEMIC_PROFILE=$EPYDEMIC_PROFILE
ENV EPYDEMIC_PROFILE_DIR=".ipython/profile_$EPYDEMIC_PROFILE/"
ENV EPYDEMIC_CONTROLLER_FILE="$EPYDEMIC_PROFILE_DIR/ipcontroller_config.py"
RUN ipython profile create --parallel $EPYDEMIC_PROFILE
RUN cat >>$EPYDEMIC_CONTROLLER_FILE <<EOF
# Listen on all interfaces
c.IPController.ip = ''

# ssh-based cluster, without secure authentication or encryption (we assume
# we're running on a secure network)
c.IPClusterEngines.engine_launcher_class = 'SSHEngineSetLauncher'
c.IPController.enable_curve = False
c.SSHLauncher.to_send = []
c.SSHLauncher.to_fetch = []

# Persistent store for jobs
c.IPControiller.db_class = 'SQLiteDB'
EOF

# Expose the server's ports
EXPOSE 22/tcp

# Run the server
#ENTRYPOINT ["./start_controller.sh"]
ENTRYPOINT ["/bin/bash"]

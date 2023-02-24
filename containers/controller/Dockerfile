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

ARG BASE_IMAGE="python:3.9"

# Base image
FROM $BASE_IMAGE
LABEL description="cloud-epydemic compute cluster controller"
LABEL maintainer="Simon Dobson <simon.dobson@st-andrews.ac.uk>"

# Install the HDF5 libraries needed by epyc and ipyparallel
USER root
RUN <<EOF
apt update
apt-get install -y hdf5-tools
apt-get install -y sqlite3
EOF

# Add a user
ARG EPYDEMIC_USER="epydemic"
ENV EPYDEMIC_HOME="/home/$EPYDEMIC_USER"
RUN useradd -m -d $EPYDEMIC_HOME -s /bin/bash $EPYDEMIC_USER

# Install the additional Python dependencies
WORKDIR $EPYDEMIC_HOME
COPY ./requirements.txt .
RUN chown $EPYDEMIC_USER requirements.txt
RUN pip install --upgrade pip wheel
RUN pip install --no-cache-dir -r requirements.txt

# Switch to the non-root user
USER $EPYDEMIC_USER

# Set up the controller configuraiton
ARG EPYDEMIC_PROFILE="epydemic"
ENV EPYDEMIC_PROFILE_DIR=".ipython/profile_$EPYDEMIC_PROFILE/"
RUN ipython profile create --parallel $EPYDEMIC_PROFILE
RUN cat >>$EPYDEMIC_PROFILE_DIR/ipcontroller_config.py <<EOF
# Listen on all interfaces
c.IPControllerApp.ip = ''

# ssh-based cluster
c.IPClusterEngines.engine_launcher_class = 'SSHEngineSetLauncher'
c.SSHLauncher.to_send = []
c.SSHLauncher.to_fetch = []

# Persistent store for jobs
c.HubFactory.db_class = 'SQLiteDB'
EOF

# Expose the server's ports
EXPOSE 22/tcp

# Run the server, binding to all addresses to avoid issues with virtual networks
#ENTRYPOINT ["ipython", "notebook"]
ENTRYPOINT ["/bin/bash"]

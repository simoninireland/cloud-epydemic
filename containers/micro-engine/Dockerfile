# Dockerfile for engine microservice
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

# The build context for this Dockerfile should be the directory
# above, to allow access to files in lib/

# Base image can be provided at build-time, and must use the same
# Python version across the cluster to avoid issues with code serialisation
ARG BASE_IMAGE="python:3.9"

# Base image
FROM $BASE_IMAGE
LABEL description="cloud-epydemic compute engine microservice"
LABEL maintainer="Simon Dobson <simon.dobson@st-andrews.ac.uk>"

# Build-time arguments to configure the cluster
ARG EPYDEMIC_USER="epydemic"

# Install the HDF5 libraries needed by epyc
USER root
RUN <<EOF
apt update
apt-get install -y hdf5-tools
EOF

# Add a user
ENV EPYDEMIC_USER="$EPYDEMIC_USER"
ENV EPYDEMIC_HOME="/home/$EPYDEMIC_USER"
RUN useradd -m -d $EPYDEMIC_HOME -s /bin/bash $EPYDEMIC_USER

# Install the additional Python dependencies
WORKDIR $EPYDEMIC_HOME
COPY micro-engine/requirements.txt .
RUN pip install --upgrade pip wheel
RUN pip install --no-cache-dir -r requirements.txt

# Install the API server
COPY micro-engine/micro_engine/ ./micro_engine/
RUN chown -R $EPYDEMIC_USER ./micro_engine
COPY micro-engine/start.sh .
RUN chown $EPYDEMIC_USER ./start.sh
RUN chmod u+x ./start.sh
COPY micro-engine/start_engine.py .
RUN chown $EPYDEMIC_USER ./start_engine.py

# Expose the http and https ports
EXPOSE 80
EXPOSE 443

# Run the start-up script
USER $EPYDEMIC_USER
ENTRYPOINT ["./start.sh"]

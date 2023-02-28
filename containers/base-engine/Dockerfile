# Dockerfile to create a compute cluster engine
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
LABEL description="cloud-epydemic compute cluster engine"
LABEL maintainer="Simon Dobson <simon.dobson@st-andrews.ac.uk>"

# Build-time arguments to configure the cluster
ARG EPYDEMIC_USER="epydemic"
ARG EPYDEMIC_PROFILE="epydemic"

# Install the HDF5 libraries needed by epyc and ipyparallel
USER root
RUN <<EOF
apt update
apt-get install -y hdf5-tools
apt-get install -y sqlite3 openssh-server sudo
EOF

# Add a user
ENV EPYDEMIC_USER="$EPYDEMIC_USER"
ENV EPYDEMIC_HOME="/home/$EPYDEMIC_USER"
RUN useradd -m -d $EPYDEMIC_HOME -s /bin/bash $EPYDEMIC_USER

# Install the additional Python dependencies
WORKDIR $EPYDEMIC_HOME
COPY ./requirements.txt .
RUN chown $EPYDEMIC_USER requirements.txt
RUN pip install --upgrade pip wheel
RUN pip install --no-cache-dir -r requirements.txt

# Install the root start-up and engine start-up scripts
COPY ./start.sh .
RUN chmod u+x start.sh
COPY ./start_engine.sh .
RUN chown $EPYDEMIC_USER start_engine.sh
RUN chmod u+x start_engine.sh

# Start the ssh server for tunnelling using keypairs only
EXPOSE 22
RUN service ssh start
#RUN echo "PasswordAuthentication no" >/etc/ssh/sshd_config
RUN echo "epydemic:secret" | chpasswd

# Create mount point for the shared working storage
ENV EPYDEMIC_STORAGE=shared
RUN mkdir $EPYDEMIC_STORAGE
RUN chown $EPYDEMIC_USER $EPYDEMIC_STORAGE

# Switch to the non-root user
USER $EPYDEMIC_USER

# Create links
ENV EPYDEMIC_PROFILE="$EPYDEMIC_PROFILE"
RUN ln -s $EPYDEMIC_STORAGE/.ipython .ipython
RUN ln -s $EPYDEMIC_STORAGE/.ssh .ssh

# Run the start-up script, which starts sshd and ipengine
USER root
ENTRYPOINT ["./start.sh"]
#ENTRYPOINT ["/bin/bash"]

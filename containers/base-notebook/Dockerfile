# Dockerfile to create a notebook container
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

# We can't use the jupyter/base-notebook base image as it doesn't
# commit to a Python version, which we need to avoid issues with
# ipyparallel passing closures around. A lot of what follows is
# taken from https://hub.docker.com/r/jupyter/base-notebook/dockerfile#!
ARG BASE_IMAGE="python:3.9"

# Base image
FROM $BASE_IMAGE
LABEL description="cloud-epydemic Jupyter notebook server"
LABEL maintainer="Simon Dobson <simon.dobson@st-andrews.ac.uk>"

# Install the HDF5 libraries needed by epyc, and the other
# libraries needed by ipyparallel and Jupyter
USER root
RUN <<EOF
apt update
apt-get install -y hdf5-tools
apt-get install -y ca-certificates locales fonts-liberation openssh-client
EOF
RUN echo "en_US.UTF-8 en_GB.UTF-8 UTF-8" >/etc/locale.gen && locale-gen

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

# Create mount point for the shared working storage
ENV EPYDEMIC_STORAGE=shared
RUN mkdir $EPYDEMIC_STORAGE
RUN chown $EPYDEMIC_USER $EPYDEMIC_STORAGE

# Switch to the non-root user
USER $EPYDEMIC_USER

# Create links
RUN ln -s $EPYDEMIC_STORAGE/.ipython .ipython
RUN ln -s $EPYDEMIC_STORAGE/.ssh .ssh

# Set up password security instead of access tokens
ARG EPYDEMIC_PASSWORD=""
RUN jupyter notebook --generate-config
RUN cat >>.jupyter/jupyter_notebook_config.py <<EOF
c.NotebookApp.token = ""
c.NotebookApp.password = "$EPYDEMIC_PASSWORD"
EOF

# Run the server, binding to all addresses to avoid issues with virtual networks
EXPOSE 8888
ENTRYPOINT ["jupyter", "notebook", "--ip=0.0.0.0"]
#ENTRYPOINT ["/bin/bash"]

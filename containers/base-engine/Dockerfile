# Dockerfile to create a compute engine
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

FROM python:3.9
LABEL description="cloud-epydemic ipyparallel compute server"
LABEL maintainer="Simon Dobson <simon.dobson@st-andrews.ac.uk>"

# Install the HDF5 libraries needed by epyc
USER root
RUN apt update
RUN apt-get install -y hdf5-tools

# Install the additional Python dependencies
WORKDIR /home/jovyan
COPY ./requirements.txt .
RUN pip install --upgrade pip wheel
RUN pip install --no-cache-dir -r requirements.txt

# Expose the notebook's port
EXPOSE 8888/tcp

# Switch back to the non-root user before running the server
USER jovyan
ENTRYPOINT ["jupyter", "notebook"]

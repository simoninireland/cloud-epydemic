#!/bin/sh
#
# Start-up script for clkuster frontend notebook server
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

# We expect two environment variables to be defined by the container:
#
# - EPYDEMIC_HOME -- the home directory
# - EPYDEMIC_DATA -- the directory containing the notebooks and data
#
# The data directory could be a mount  point, to allow notebooks and data
# to persist.
#
# We also accept one run-time variable:
#
# - EPYDEMIC_PASSWORD -- the password for accessing the notebook server
#
# The password is blank by default.

# Grab password
PASSWORD=${EPYDEMIC_PASSWORD:-}

# Create a SHA1 hash in the correct format
RAWHASH=`echo $PASSWORD | sha1sum | cut -d ' ' -f 1`
HASH="sha1:$RAWHASH"

# Disable token-based access control and install a password
cd $EPYDEMIC_HOME
jupyter notebook --generate-config
cat >>.jupyter/jupyter_notebook_config.py <<EOF
c.NotebookApp.token = ""
c.NotebookApp.password = "$HASH"
EOF

# Start the notebook server
cd $EPYDEMIC_DATA
jupyter notebook --ip=0.0.0.0

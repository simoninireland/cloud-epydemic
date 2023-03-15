# Services exported from lab notebooks
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

import micro_labnotebook


def addResultSet(rsdesc):
    '''Add a new result set to the notebook.

    @param rsdesc: a dict with tag and (optional) description'''
    tag = rsdesc['tag']
    desc = rsdesc.get('description', None)

    # add the new results set
    micro_labnotebook.nb.addResultSet(tag, description=desc)
    return dict()

def addResult(rsrc):
    '''Add a results dict to a specific results set.

    @param rsrc: a dict with a results dict and optional result set name'''
    rc = rsrc['results']
    rs = rsrc.get('resultset', None)

    # add the results to the lab notebook
    micro_labnotebook.nb.addResult(rc, tag=rs)
    return dict()

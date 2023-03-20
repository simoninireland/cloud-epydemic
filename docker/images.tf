# Images for local Docker deployment
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

resource "docker_image" "notebook" {
  name = "simoninireland/base-notebook:latest"
  keep_locally = true
}

resource "docker_image" "controller" {
  name = "simoninireland/controller:latest"
  keep_locally = true
}

resource "docker_image" "engine" {
  name = "simoninireland/base-engine:latest"
  keep_locally = true
}

resource "docker_image" "redis" {
  name = "redis:latest"
  keep_locally = true
}

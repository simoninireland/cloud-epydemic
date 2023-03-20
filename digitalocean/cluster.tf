# Kubernetes cluster on Digital Ocean
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


resource "digitalocean_kubernetes_cluster" "k8s-cluster" {
  name    = var.k8s_application_name
  region  = var.digitalocean_region
  version = var.k8s_version

  node_pool {
    name       = "geekiam-worker-pool"
    size       = var.k8s_worker_node_shape
    node_count = var.k8s_worker_node_pool_size
  }
}



# ---------- Droplet ----------

resource "digitalocean_droplet" "cluster" {
  image = "ubuntu-20-04-x64"
  name = "cluster"
  region = "lon1"
  size = "s-1vcpu-1gb"
  ssh_keys = [
    data.digitalocean_ssh_key.cloudepydemic.id
  ]

  connection {
    host = self.ipv4_address
    user = "root"
    type = "ssh"
    private_key = file(var.private_key_file)
    timeout = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      # install nginx
      "sudo apt update",
      "sudo apt install -y nginx"
    ]
  }
}

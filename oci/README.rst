oci: Simulation setup on Oracle Cloud Infrastructure
====================================================

``terraform`` scripts to set up a Kubernetes compute cluster
on Oracle Cloud Infrastructure (OCI).

Much of the structure of these files comes from the
`Oracle Terraform tutorials
<https://docs.oracle.com/en-us/iaas/developer-tutorials/tutorials/tf-provider/01-summary.htm>`_,
modified as required by ``cloudepydemic``.


Variables
---------

There are several variables needed in order to access OCI. For
security these are held in a file ``credentials.tfvars``, which is not
version controlled.

To create this file, copy ``credentials.example`` to
``credentials.tfvars`` and fill-in the variables, all of which are
quoted strings. None of these values have defaults, so all must be supplied.

+-------------------+------------------------------------------+----------------+
| Variable          | Description                              | Example        |
+===================+==========================================+================+
| tenancy_ocid      | OCID of the tenancy                      |                |
+-------------------+------------------------------------------+----------------+
| oci_region        | The region hosting the tenancy           | uk-london-1    |
+-------------------+------------------------------------------+----------------+
| user_ocid         | OCID of the user running the cluster     |                |
+-------------------+------------------------------------------+----------------+
| key_fingerprint   | User's public key fingerprint            |                |
+-------------------+------------------------------------------+----------------+
| private_key_path  | Local path to private key in PEM format  | ~/.oci/key.pem |
+-------------------+------------------------------------------+----------------+

There are also some variables needed to configure Kubernetes. Again,
there is a file ``kubernetes.example`` that should be copieds to
``kubernetes.tfvars`` and filled in. Some of the values have defaults
to get things started; those without defaults need to be supplied.

+-----------------------------+------------------------------------------+----------------+
| Variable                    | Description                              | Default        |
+=============================+==========================================+================+
+ k8s_version                 | Kubernetes version                       |                |
+-----------------------------+------------------------------------------+----------------+
+ k8s_worker_node_shape       | Compute shape for a worker node          |                |
+-----------------------------+------------------------------------------+----------------+
+ k8s_worker_node_image_ocid  | OCID for worker node OS image            |                |
+-----------------------------+------------------------------------------+----------------+
+ k8s_worker_node_pool_size   | Number of workers in the pool            | 3              |
+-----------------------------+------------------------------------------+----------------+
+ k8s_worker_node_memory      | Memory per worker node, in GBs           | 1              |
+-----------------------------+------------------------------------------+----------------+
+ k8s_worker_node_cpus        | Virtual CPUs per worker node             | 2              |
+-----------------------------+------------------------------------------+----------------+

Note that there is an important relationship between ``k8s_version``
and ``k8s_worker_node_image_ocid``. The version of Kubernetes in the
worker node image needs to be compatible with the chosen Kubernetes
version used for the cluster and node pool. Generally the image name
includes the version number it uses.

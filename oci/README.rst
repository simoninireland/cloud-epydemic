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
quoted strings:

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
| home_address_cidr | Address block to accept connections from | 12.34.0.0/16   |
+-------------------+-------------------------------------------+---------------+

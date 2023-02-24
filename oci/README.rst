oci: Simulation setup on Oracle Cloud Infrastructure
====================================================

These ``terraform`` scripts set up a compute cluster with notebook
front-end on Oracle Cloud Infrastructure (OCI).


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
+-------------------+------------------------------------------+----------------+
| tenancy_ocid      | OCID of the tenancy                      |                |
| oci_region        | The region hosting the tenancy           | uk-london-1    |
| compartment_ocid  | OCID of the compartment for the cluster  |                |
| user_ocid         | OCID of the user running the cluster     |                |
| key_fingerprint   | User's public key fingerprint            |                |
| private_key_path  | Local path to private key in PEM format  | ~/.oci/key.pem |
| home_address_cidr | Address block to accept connections from | 12.34.0.0/16   |
+-------------------+-------------------------------------------+---------------+

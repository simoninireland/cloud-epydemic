base-notebook: Base container image for a Jupyter notebook
==========================================================

The ``base-notebook`` image contains a Jupyter notebook with enough
supporting code to hook-into an ``ipyparallel`` controller on the same
network.

The notebook disables token-based authentication and instead uses
optional password authentication. The password is empty by default,
meaning the notebook can be accessed by anyone unless security is
provided at another level.


Build-time arguments
--------------------

The following arguments (with their default values) can be provided
when re-building the image by using
``docker buildx build --build-arg <key>=<value>``:

+-------------------+-------------------------------------+------------+
| Description       | Variable                            | Default    |
+===================+=====================================+============+
| BASE_IMAGE        | The base container image            | python:3.9 |
+-------------------+-------------------------------------+------------+
| EPYDEMIC_USER     | Username for the non-root user      | epydemic   |
+-------------------+-------------------------------------+------------+


Mount points
------------

There are two mount points used by the container:

+-------------------------------+--------------------------------------+
| Path                          | Description                          |
+===============================+=========================+============+
| /home/$EPYDEMIC_USER/shared   | Shared working storage for cluster   |
+---------------------------------------------------------+------------+
| /home/$EPYDEMIC_USER/data     | Data and notebook storage            |
+-------------------------------+--------------------------------------+

The shared storage is required for the proper working of the cluster,
and should be shared by all engines. The data storage is required to
make notebooks and data persistent.


Extending the image
-------------------

This image can be used as a base for further images, which will
typically install libraries and/or Python packages to support
additional features within notebooks.

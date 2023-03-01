controller: Container image for a compute cluster controller
============================================================

The ``controller`` image contains an ``ipyparallel`` compute cluster
controller.


Build-time arguments
--------------------

The following arguments (with their default values) can be provided
when re-building the image by using
``docker buildx build -t <tag> --build-arg <key>=<value>``:

+-------------------+-------------------------------------+------------+
| Description       | Variable                            | Default    |
+===================+=====================================+============+
| BASE_IMAGE        | The base container image            | python:3.9 |
+-------------------+-------------------------------------+------------+
| EPYDEMIC_USER     | Username for the non-root user      | epydemic   |
+-------------------+-------------------------------------+------------+


Mount points
------------

There is one two mount point used by the container:

+-------------------------------+--------------------------------------+
| Path                          | Description                          |
+===============================+=========================+============+
| /home/$EPYDEMIC_USER/shared   | Shared working storage for cluster   |
+---------------------------------------------------------+------------+

This is required for the proper working of the cluster, and should be shared
by all engines.

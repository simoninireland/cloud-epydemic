base-engine: Base container image for a compute server
======================================================

The ``base-engine`` image contains an ``ipyparallel`` compute server
(engine).

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


Run-time arguments
------------------

We also accept an optional build-time variable:

+------------------+-------------------------------------------------+---------+
| Description      | Variable                                        | Default |
+===================+================================================+=========+
| EPYDEMIC_ENGINES | The number of engines to start in the container | 1       |
+------------------+-------------------------------------------------+---------+


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

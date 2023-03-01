base-notebook: Base container image for a compute server
========================================================

The ``base-engine`` image contains an ``ipyparallel`` compute server
(engine).

Build-time arguments
--------------------

The following arguments (with their default values) can be provided
when re-building the image by using
``docker buildx build -t <tag> --build-arg <key>=<value>``:

+-------------------+-------------------------------------+----------+
| Description       | Variable                             | Default |
+===================+=====================================+==========+
| EPYDEMIC_USER     | Username for the non-root user      | epydemic |
+-------------------+-------------------------------------+----------+
| EPYDEMIC_PASSWORD | Password for accessing the notebook | <empty> |
+-------------------+-------------------------------------+----------+

Run-time arguments
------------------

We also accept an optional build-time variable:

+------------------+-------------------------------------------------+---------+
| Description      | Variable                                        | Default |
+===================+================================================+=========+
| EPYDEMIC_ENGINES | The number of engines to start in the container | 1       |
+------------------+-------------------------------------------------+---------+

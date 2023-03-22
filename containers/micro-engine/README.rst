micro-engine: Base container image for a compute cluster microservice
=====================================================================

The ``micro-engine`` image contains an experiment-runner microservice
accessed through a simple web API.


Build-time arguments
--------------------

The following arguments (with their default values) can be provided
when re-building the image by using
``docker buildx build -t <tag> --build-arg <key>=<value>``:

+-------------------+-------------------------------------+------------+
| Variable          | Description                         | Default    |
+===================+=====================================+============+
| BASE_IMAGE        | The base container image            | python:3.9 |
+-------------------+-------------------------------------+------------+
| EPYDEMIC_USER     | Username for the non-root user      | epydemic   |
+-------------------+-------------------------------------+------------+

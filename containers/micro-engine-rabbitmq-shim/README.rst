micro-engine-rabbitmq-shim: Sidecar for using RabbitMq
======================================================

The ``micro-engine-rabbitmq-shim`` image is a small "shim" that allows
the ``micro-engine`` API to be called using the
[RabbitMQ](https://www.rabbitmq.com) message broker. This allows more
flexible message handling.


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


Run-time arguments
------------------

The shim is controlled by providing a number of elements in environment variables:

+------------------------------+---------------------------+------------------------------+
| Variable                     | Description               | Default                      |
+==============================+===========================+==============================+
| EPYDEMIC_ENGINE_API_ENDPOINT | Engine API endpoint       | http://localhost:5000/api/v1 |
+------------------------------+---------------------------+------------------------------+
| RABBITMQ_HOST                | Message broker hostname   | localhost                    |
+------------------------------+---------------------------+------------------------------+
| RABBITMQ_REQUEST_CHANNEL     | Channel name for requests | request                      |
+------------------------------+---------------------------+------------------------------+
| RABBITMQ_RESULT_CHANNEL      | Channel name for results  | result                       |
+------------------------------+---------------------------+------------------------------+

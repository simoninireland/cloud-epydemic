base-notebook: Base container image for a compute server
========================================================

The ``base-engine`` image contains an ``ipyparallel`` compute server
(engine).

Build-time arguments
--------------------

The following arguments (with their default values) can be provided
when re-building the image by using
``docker buildx build -t <tag> --build-arg <key>=<value>``:

``EPYDEMIC_USER`` -- username for the non-root user ("epydemic")

``EPYDEMIC_PROFILE`` -- the ``ipyparallel`` profile name ("epydemic")

# Services exported from the web API to RabbitMQ messages
#
# Copyright (C) 2023 Simon Dobson
#
# This file is part of cloud-epydemic, network simulation as a service
#
# cloud-epydemic is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published byf
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# cloud-epydemic is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with cloud-epydemic. If not, see <http://www.gnu.org/licenses/gpl.html>.

import os
import sys
import time
import base64
import json
import pickle
import logging
from tempfile import NamedTemporaryFile
from urllib.parse import urlparse
from retry import retry
import pika
from epyc import Experiment


# Grab environment variables
rabbitmq = os.environ["RABBITMQ_ENDPOINT"]
requestQueue = os.environ["RABBITMQ_REQUEST_QUEUE"]
resultQueue = os.environ["RABBITMQ_RESULT_QUEUE"]
logLevel = os.environ.get("RABBITMQ_LOGLEVEL", logging.INFO)

EXPERIMENT_ID = "epyc.experiment.id"

# Set up logging
logger = logging.getLogger(__name__)
logger.setLevel(logLevel)
ch = logging.StreamHandler()
logger.addHandler(ch)


# ---------- Helper functions ----------

@retry(tries=5, delay=1, backoff=3, logger=logger)
def _connect(u):
    '''Basic connection operation to connect to RabbitMQ endpoint.

    :param u: the parsed URL of the endpoint
    :returns: the channel'''

    # connect to broker using TLS
    params = pika.ConnectionParameters(host=u.hostname,
                                       port=u.port)
    connection = pika.BlockingConnection(params)
    channel = connection.channel()

    return channel

def connect(endpoint):
    '''Connect to the RabbitMQ message broker endpoint.

    :param endpoint: the endpoint
    :returns: the channel'''

    logger.info(f"Connecting to {endpoint}")
    u = urlparse(endpoint)
    channel = _connect(u)
    logger.info(f"Connected")

    # ensure the queues exist
    for ch in ["request", "result"]:
        channel.queue_declare(queue=ch)

    return channel


# ---------- API functions ----------

def runExperimentAsync(submission):
    '''Run an experiment asynchronously. The experiment is submitted
    to the message broker's request channel.

    :param submission: experiment and its parameters'''
    channel = connect(rabbitmq)
    args = json.dumps(submission)
    logger.info("runExperimentAsync()")
    logger.debug(str(args))
    channel.basic_publish(exchange='',
                          routing_key=requestQueue,
                          body=args)
    channel.close()

    # return an empty body
    return ''


def getPendingResults():
    '''Retrieve all pending results. This reads messages from the
    message broker's result channel and returns them as an array.

    :returns: an array of results'''
    channel = connect(rabbitmq)
    logger.info("getPendingResults()")
    results = []
    message = 1
    while message is not None:
        message, properties, body = channel.basic_get(resultQueue)
        if message is not None:
            rc = json.loads(body)

            # retrieve the id
            id = rc[Experiment.METADATA][EXPERIMENT_ID]

            # package the result
            r = dict(id=id,
                     resultsDict=rc)
            results.append(r)
    channel.close()

    # return the array
    return results

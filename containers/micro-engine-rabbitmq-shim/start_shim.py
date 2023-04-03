#!/usr/bin/env python
#
# Start-up script for compute engine shim for RabbitMQ
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

import sys
import os
import json
import time
from datetime import datetime
import logging
import logging.handlers
import pika
from retry import retry
import requests


# Grab environment variables
endpoint = os.environ["EPYDEMIC_ENGINE_API_ENDPOINT"]
rabbitmq = os.environ["RABBITMQ_ENDPOINT"]
requestQueue = os.environ["RABBITMQ_REQUEST_QUEUE"]
resultQueue = os.environ["RABBITMQ_RESULT_QUEUE"]
logLevel = os.environ.get("RABBITMQ_LOGLEVEL", logging.INFO)
retries = 5

# Set up logging
logger = logging.getLogger(__name__)
logger.setLevel(logLevel)
ch = logging.StreamHandler()
logger.addHandler(ch)

# Connect to Rabbitmq
@retry(tries=5, delay=1, backoff=3, logger=logger)
def connect(endpoint):
    '''Connect to the RabbitMQ endpoint.

    :param endpoint: the endpoint
    :returns: the channel'''
    logger.info(f"Connecting to {rabbitmq}")
    connection = pika.BlockingConnection(pika.URLParameters(rabbitmq))
    channel = connection.channel()
    logger.info(f"Connected")

    # ensure the queues exist
    for ch in ["request", "result"]:
        channel.queue_declare(queue=ch)
    return channel

# Define the callback
def requestHandler(ch, method, properties, body):
    """Handle an incoming request. The method body is
    passed to the engine microservice API "/runExperiment"
    path, with the returned results dict being set as a message
    on the reesult channel. The request message is then acknowledged.

    :param ch: the channel
    :param method: the method identifier
    :param properties: the method properties
    :param body: the method body"""
    tag = method.delivery_tag
    logger.info(f"Request {tag} received")
    start = datetime.now()

    # make call to API
    args = json.loads(body)
    res = requests.post(f"{endpoint}/runExperiment", json=args)

    # post the result to the result queue
    args = json.dumps(res.json())
    channel.basic_publish(exchange='',
                          routing_key=resultQueue,
                          body=args)

    # acknowledge that the request has now been dealt with
    channel.basic_ack(delivery_tag=tag)
    end = datetime.now()
    dt = end - start
    logger.info(f"Request {tag} completed (elapsed time = {dt}")

# Connect to RabbitMQ
channel = connect(rabbitmq)

# Register the callback for incoming requests
channel.basic_consume(queue=requestQueue,
                      on_message_callback=requestHandler,
                      auto_ack=False)

# Run the messaging loop
logger.debug("Starting message loop")
channel.start_consuming()

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
import pika
import requests


# Grab environment variables
endpoint = os.environ["EPYDEMIC_ENGINE_API_ENDPOINT"]
rabbitmq = os.environ["RABBITMQ_ENDPOINT"]
requestQueue = os.environ["RABBITMQ_REQUEST_QUEUE"]
resultQueue = os.environ["RABBITMQ_RESULT_QUEUE"]

# Set up logging
logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)
ch = logging.StreamHandler()
ch.setLevel(logging.DEBUG)
logger.addHandler(ch)
#LOG_FILENAME = os.environ.get('LOGFILE') or 'shim.log'
#handler = logging.handlers.TimedRotatingFileHandler(LOG_FILENAME,
#                                                    when='midnight',
#                                                    backupCount=7)
#formatter = logging.Formatter('%(levelname)s:%(name)s: [%(asctime)s] %(message)s',
#                              datefmt='%d/%b/%Y %H:%M:%S')
#logger.addHandler(handler)
#handler.setFormatter(formatter)

# Define the callback
def requestHandler(ch, method, properties, body):
    """Handle an incoming request. The method body is
    passed to the engine microservice API "/runExperiment"
    path, with the returned results dict being set as a message
    on the reesult channel. The request message is then acknowledged.

    @param ch: the channel
    @param method: the method identifier
    @param properties: the method properties
    @param body: the method body"""
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
logger.info(f"Connecting to RabbitMQ at {rabbitmq}")
connection = None
channel = None
try:
    connection = pika.BlockingConnection(pika.URLParameters(rabbitmq))
    channel = connection.channel()
except Exception as e:
    logger.warning(f"Failed to connect ({e}); re-trying...")
    time.sleep(5)
logger.info(f"Connected")

# Ensure the channels exist
for ch in [requestQueue, resultQueue]:
    logger.info(f"Creating queue {ch}")
    channel.queue_declare(queue=ch)

# Register the callback for incoming requests
channel.basic_consume(queue=requestQueue,
                      on_message_callback=requestHandler,
                      auto_ack=False)

# Run the messaging loop
logger.debug("Starting message loop")
channel.start_consuming()

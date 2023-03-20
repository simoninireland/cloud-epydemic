#!env python
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
import logging
import pika
import requests


# API endpoints
RUNEXPERIMENT_API = "/api/v1/runExperiment"

# Grab environment variables
engine = os.environ["EPYDEMIC_ENGINE_HOST"]
rabbitmq = os.environ["RABBITMQ_HOST"]
requestChannel = os.environ["RABBITMQ_REQUEST_CHANNEL"]
resultChannel = os.environ["RABBITMQ_RESULT_CHANNEL"]

# Set up logging
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
LOG_FILENAME = os.environ.get('LOGFILE') or 'shim.log'
handler = logging.handlers.TimedRotatingFileHandler(LOG_FILENAME,
                                                    when='midnight',
                                                    backupCount=7)
formatter = logging.Formatter('%(levelname)s:%(name)s: [%(asctime)s] %(message)s',
                              datefmt='%d/%b/%Y %H:%M:%S')
logger.addHandler(handler)
handler.setFormatter(formatter)

# Define the callback
def requestHandler(ch, message, properties, body):
    """Handle an incoming request. The message body is
    passed to the engine microservice API "/runExperiment"
    path, with the returned results dict being set as a message
    on the reesult channel.

    @param ch: the channel
    @param message: the message identifier
    @param properties: message properties
    @param body: message body"""

    # make call to API
    endpoint = f"{engine}{RUNEXPERIMENT_API}"
    res = requests.post(endpoint, json=body)

    # return the result to the result channel
    channel.basic_publish(exchange='',
                          routing_key=resultChannel,
                          body=res.body)


# Configure the message shim
connection = pika.BlockingConnection(pika.ConnectionParameters(host=host))
channel = connection.channel()

# Ensure the channels exist
for ch in [requestChannel, resultChannel]:
    channel.queue_declare(queue=ch)

# Register the callback
channel.basic_consume(queue=requestChannel,
                      on_message_callback=shimCallback,
                      auto_ack=False)

# Run the messaging loop
channel.start_consuming()

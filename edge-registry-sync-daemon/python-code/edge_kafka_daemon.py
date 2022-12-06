#	This file is part of Edge Registry Syncer.
#
#    Edge Registry Syncer is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Edge Registry Syncer is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with Edge Registry Syncer.  If not, see https://www.gnu.org/licenses/.

import json, kafka, logging, random, requests, os
from datetime import datetime

logging.basicConfig(level=logging.INFO)
kafkaAddress = os.getenv('KAFKA_ADDRESS')

def list_topics():
    consumer = kafka.KafkaConsumer(
        bootstrap_servers=[kafkaAddress],
        auto_offset_reset='earliest',
        enable_auto_commit=True,
        group_id=None,
        value_deserializer=lambda x: json.loads(x.decode('utf-8')))
    topics = consumer.topics()
    for topic in topics:
        print(topic)

def receive_messages(topic):
    consumer = kafka.KafkaConsumer(
        topic,
        bootstrap_servers=[kafkaAddress],
        auto_offset_reset='earliest',
        enable_auto_commit=True,
        group_id=None,
        value_deserializer=lambda x: json.loads(x.decode('utf-8')))
    for message in consumer:
        message = message.value
        print(message)
        component = message.get("component","default")
        appName = message.get("applicationName","NONAME")
        appVersion = message.get("applicationVersion",'0.0.0')
        appType = None
        appURI = None
        if "uri" in message:
            appType = "VM"
            appURI = message["uri"]
        elif "location" in message:
            appType = "Docker"
            appURI = message["location"]
        else:
            print("ERROR!")
            print(message)
            print()
        resultObj = {'appName':appName,'appVersion':appVersion,'appType':appType,'appURI':appURI,'component':component}
        print(f'Sending {resultObj}.')
        print(requests.post('http://localhost:2022/kafka', data = resultObj))
        
#list_topics()
receive_messages('edge.model.image.vm')
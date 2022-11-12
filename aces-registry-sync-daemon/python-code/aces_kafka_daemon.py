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
receive_messages('accordion.model.image.vm')
#!/usr/bin/env python
# coding=utf-8
import pika

credentials = pika.PlainCredentials('admin', 'adminpass')
parameters = pika.ConnectionParameters('192.168.1.1', credentials=credentials)
connection = pika.BlockingConnection(parameters)

#connection = pika.BlockingConnection(pika.ConnectionParameters('192.168.1.1'))
channel = connection.channel()
channel.queue_declare(queue='test')
channel.basic_publish(exchange='', routing_key='test', body='Hello Netology!')
connection.close()

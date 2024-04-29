############################################################################################################
# Group 34 - CloudClan                                                                                     #
#                                                                                                          #
# References used:                                                                                         #
# https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/dynamodb.html                 #
# https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/sns.html                      # 
#                                                                                                          #
#                                                                                                          #
############################################################################################################




import json
import os
import boto3
import botocore
import base64
from boto3.dynamodb.conditions import Key, Attr

def lambda_handler(event, context):
  print(event['context']['http-method'])
  print(event['context']['resource-path'])
  print(event)
  if event['context']['http-method'] == 'GET' and event['context']['resource-path'] == '/get-approved-event':
    response = fetchAllApprovedEvents(event, context) 
    return response
  elif event['context']['http-method'] == 'POST' and event['context']['resource-path'] == '/book-event':
    response = bookEvent(event, context) 
    return response

def fetchAllApprovedEvents(event, context):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('EventifyEvents')
    response = table.scan(
        FilterExpression=Attr('event_isApproved').eq(True)
    )
    return {
            "statusCode" : "200",
            "message": "All Approved Events",
            "events" : response['Items']
            
    } 

def bookEvent(event, context):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('EventifyEvents')
    event_id = event['body-json']['event_id']
    attendee_username = event['body-json']['attendee_username']
    attendee_email = event['body-json']['attendee_email']
    print(event_id)
    response = table.get_item(Key={'event_id': event_id})
    print(response)
    currentEvent = response['Item']
    print(currentEvent)
    if currentEvent['event_availability'] and currentEvent['event_isApproved']:
        print(len(currentEvent['event_participants']))
        currentEvent['event_participants'].append(attendee_username)
        
        snsClient = boto3.client('sns')
        event_name = currentEvent['event_title']
        
        response = snsClient.publish(
            TopicArn='arn:aws:sns:us-east-1:359996502019:SNSRegisterConfirmation',
            Message="Your registration for  \""+ event_name + "\" is succesfull. See you there!!",
            Subject='Event Bookin Succesfull',
            MessageStructure='string',
            MessageAttributes={
                'email': {
                    'DataType': 'String',
                    'StringValue': attendee_email
                }
            }
        )  
        
        if int(currentEvent['event_max_capacity']) == len(currentEvent['event_participants']):
            currentEvent['event_availability'] = False
        table.put_item(Item=currentEvent)
        
        
        return {
                "statusCode" : "200",
                "message": "Booking successful.",
        }
    else:
        return {
            "statusCode" : "400",
            "message": "Sorry! This event is full."
        }
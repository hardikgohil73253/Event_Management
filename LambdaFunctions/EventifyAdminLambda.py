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

def lambda_handler(event, context):
  print(event)
  if event['context']['http-method'] == 'GET' and event['context']['resource-path'] == '/admin-get-events':
    response = getAllEvent(event, context) 
    return response
  elif event['context']['http-method'] == 'GET' and event['context']['resource-path'] == '/get-event':
    print(event['params']['querystring']['event_id'])
    response = getEventByID(event, context) 
    return response
  elif event['context']['http-method'] == 'GET' and event['context']['resource-path'] == '/admin-event-approve':
    print(event['params']['querystring']['event_id'])
    response = getEventApprove(event, context) 
    return response
  elif event['context']['http-method'] == 'GET' and event['context']['resource-path'] == '/admin-event-reject':
    print(event['params']['querystring']['event_id'])
    response = getEventReject(event, context) 
    return response
    
def getAllEvent(event, context):

  dynamodb = boto3.resource('dynamodb')
  table = dynamodb.Table('EventifyEvents')
  response = table.scan()
  print(response)
  return {
      "statusCode" : "200",
      "message": "All events are retrieved sucessfully",
      "events" : response["Items"]
  }

def getEventByID(event, context):

  dynamodb = boto3.resource('dynamodb')
  table = dynamodb.Table('EventifyEvents')
  response = table.get_item(Key={'event_id': event['params']['querystring']['event_id']})
  return {
      "statusCode" : "200",
      "message": "event retrieved",
      "events" : response['item']
  }
  
def getEventApprove(event, context):

  dynamodb = boto3.resource('dynamodb')
  table = dynamodb.Table('EventifyEvents')
  dynamodbResponse = table.get_item(Key={'event_id': event['params']['querystring']['event_id']})
  print(dynamodbResponse)
  
  snsClient = boto3.client('sns')
  email = dynamodbResponse['Item']['event_organizer_email']
  event_name = dynamodbResponse['Item']['event_title']
  print(email)
  response = snsClient.publish(
      TopicArn='arn:aws:sns:us-east-1:359996502019:SNSRegisterConfirmation',
      Message="Your Event \""+ event_name + "\" is Approved. Thank you for being our valuable customer.",
      Subject='Event Approved',
      MessageStructure='string',
      MessageAttributes={
          'email': {
              'DataType': 'String',
              'StringValue': email
          }
      }
  )  
  
  table.update_item(
    Key={'event_id': event['params']['querystring']['event_id']},
    UpdateExpression="SET event_isApproved = :approved",
        ExpressionAttributeValues={":approved": True},
  )
  
  return {
      "statusCode" : "200",
      "message": "event approved"
  }
  
def getEventReject(event, context):

  dynamodb = boto3.resource('dynamodb')
  table = dynamodb.Table('EventifyEvents')
  dynamodbResponse = table.get_item(Key={'event_id': event['params']['querystring']['event_id']})
  print(dynamodbResponse)
  
  snsClient = boto3.client('sns')
  email = dynamodbResponse['Item']['event_organizer_email']
  event_name = dynamodbResponse['Item']['event_title']
  print(email)
  response = snsClient.publish(
      TopicArn='arn:aws:sns:us-east-1:359996502019:SNSRegisterConfirmation',
      Message="Your Event \""+ event_name + "\" is rejected.",
      Subject='Event Rejected',
      MessageStructure='string',
      MessageAttributes={
          'email': {
              'DataType': 'String',
              'StringValue': email
          }
      }
  )  
  
  table.update_item(
    Key={'event_id': event['params']['querystring']['event_id']},
    UpdateExpression="SET event_isRejected = :rejected",
        ExpressionAttributeValues={":rejected": True},
  )
  
  return {
      "statusCode" : "200",
      "message": "event rejected"
  }
############################################################################################################
# Group 34 - CloudClan                                                                                     #
#                                                                                                          #
# References used:                                                                                         #
# https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/dynamodb.html                 #
# https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/sns.html                      #
# https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/cognito-idp.html              # 
# https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/s3.html                       #
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
  
  # if event['context']['http-method'] == 'POST' and event['context']['resource-path'] == '/upload':
  #   response = upload(event, context) 
  #   return response
  if event['context']['http-method'] == 'POST' and event['context']['resource-path'] == '/create-event':
    response = createEvent(event, context) 
    return response
  elif event['context']['http-method'] == 'GET' and event['context']['resource-path'] == '/get-organizer-event':
    print(event['params']['querystring']['organizer_email'])
    response = fetchEventbyorganizer(event, context) 
    return response  
  elif event['context']['http-method'] == 'GET' and event['context']['resource-path'] == '/get-participants':
    response = getParticipantsDetails(event, context) 
    return response
  elif event['context']['http-method'] == 'POST' and event['context']['resource-path'] == '/delete-event':
    response = deleteEvent(event, context) 
    return response
  
        
def createEvent(event, context):

    # event_id=event['body-json']['event_id']
    # event_title=event['body-json']['event_title']
    # event_description=event['body-json']['event_description']
    # event_organizer_email=
    # event_start_time=
    # event_start_date=
    # event_venue=
    # event_s3_url=
    # event_isApproved=
    # event_participants=
    # event_max_capacity=
    # event_availability=
    
    
    s3upload = boto3.client("s3")
    imageName = event['body-json']['event_image_name']
    imageBody = event['body-json']['event_image_body']
    imageBody = imageBody[imageBody.find(",")+1:]
    decodedBody = base64.b64decode(imageBody + "===")
    s3_upload = s3upload.put_object(Bucket="eventifys3media", Key= imageName + ".jpeg", Body=decodedBody, ContentType = "image/jpeg")
    
    
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('EventifyEvents')
    response = table.put_item(
      Item={
         
            'event_id' : event['body-json']['event_id'],
            'event_title' : event['body-json']['event_title'],
            'event_description' : event['body-json']['event_description'],
            'event_organizer_email' : event['body-json']['event_organizer_email'],
            'event_start_time' : event['body-json']['event_start_time'],
            'event_start_date' : event['body-json']['event_start_date'],
            'event_venue' : event['body-json']['event_venue'],
            'event_s3_url' : event['body-json']['event_s3_url'],
            'event_isApproved' : event['body-json']['event_isApproved'],
            'event_participants' : event['body-json']['event_participants'],
            'event_max_capacity' : event['body-json']['event_max_capacity'],
            'event_availability' : event['body-json']['event_availability'],
            'event_isRejected' : event['body-json']['event_isRejected']
        }
    )
  
    snsClient = boto3.client('sns')
    email = event['body-json']['event_organizer_email']
    event_name = event['body-json']['event_title']
    print(email)
    response = snsClient.publish(
        TopicArn='arn:aws:sns:us-east-1:359996502019:SNSRegisterConfirmation',
        Message="Your Event \""+ event_name + "\" created succesfully. You will be notified when administrartor make the decision.",
        Subject='Event creation - succesfull',
        MessageStructure='string',
        MessageAttributes={
            'email': {
                'DataType': 'String',
                'StringValue': email
            }
        }
    )  
      
    return {
            "statusCode" : "200",
            "message": "Event created sucessfully"
    }
    
def fetchEventbyorganizer(event, context):
    organizer_email = event['params']['querystring']['organizer_email']
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('EventifyEvents')
    response = table.scan(
        FilterExpression=Attr('event_organizer_email').eq(organizer_email)
    )
    return {
            "statusCode" : "200",
            "message": "Successfully retrieved event by organizer email",
            "events" : response['Items']
    }
    

def getParticipantsDetails(event, context):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('EventifyEvents')
    event_id = event['params']['querystring']['event_id']
    fetchedEvent = table.get_item(Key={'event_id': event_id})
    eventParticipants = fetchedEvent['Item']['event_participants']
    # print(eventParticipants)
    client = boto3.client(
        'cognito-idp', region_name=os.getenv('COGNITO_REGION_NAME'))
    responseParticipants = []
    
    for i in eventParticipants:
        userDetails = client.admin_get_user(
            UserPoolId=os.getenv('COGNITO_USER_POOL_ID'),
            Username=i
        )['UserAttributes']
        responseParticipants.append({
            "name": userDetails[3]['Value'] + ' ' + userDetails[5]['Value'],
            "email": userDetails[6]['Value'],
        })
    return {
        "statusCode": "200",
        "message": "Fetched Successfully",
        "participants": responseParticipants
    }

def deleteEvent(event, context):
    
    try:
    
        event_id = event['body-json']['event_id']
        
        dynamodb = boto3.resource('dynamodb')
        table = dynamodb.Table('EventifyEvents')
  
        table.delete_item(
            Key={
                'event_id': event_id,
            }
        )
        return {
            "statusCode": "200",
            "message": "Event deleted successfully.",
        }
    except:
        return{
            "statusCode":"401",
            "message": "Something went wrong!"
        }

############################################################################################################
# Group 34 - CloudClan                                                                                     #
#                                                                                                          #
# References used:                                                                                         #
# https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/cognito-idp.html              #                
#                                                                                                          #
#                                                                                                          #
############################################################################################################



import json
import os
import boto3
import botocore

def lambda_handler(event, context):
  print(event['context']['http-method'])
  print(event['context']['resource-path'])
  if event['context']['http-method'] == 'POST' and event['context']['resource-path'] == '/register':
    response = register(event, context)
    return response
  elif event['context']['http-method'] == 'POST' and event['context']['resource-path'] == '/confirmregister':
    response = confirm_register(event, context)
    return response
  elif event['context']['http-method'] == 'POST' and event['context']['resource-path'] == '/login':
    response = login(event, context)
    return response
    
def register(event, context):
    
    client = boto3.client('cognito-idp', region_name=os.getenv('COGNITO_REGION_NAME'))
    snsClient = boto3.client('sns')
    try:
        response = client.sign_up(
            ClientId=os.getenv('COGNITO_USER_CLIENT_ID'),
            Username=event['body-json']['username'],
            Password=event['body-json']['password'],
            UserAttributes=[
                {
                    'Name': 'custom:firstname',
                    'Value': event['body-json']['firstname']
                },
                {
                    'Name': 'custom:lastname',
                    'Value': event['body-json']['lastname']
                },
                {
                    'Name': 'birthdate',
                    'Value': event['body-json']['birthdate']
                },
                {
                    'Name': 'profile',
                    'Value': event['body-json']['profile']
                }
            ]
        )
        
        email = event['body-json']['username']
        dictSubscriptionArn = snsClient.subscribe(
            TopicArn='arn:aws:sns:us-east-1:359996502019:SNSRegisterConfirmation',
            Protocol='email',
            Endpoint=event['body-json']['username'],
            ReturnSubscriptionArn=True
        )
        
        
        
        responseSns = snsClient.set_subscription_attributes(
            SubscriptionArn=dictSubscriptionArn['SubscriptionArn'],
            AttributeName='FilterPolicy',
            AttributeValue='{ \"email\": [ \"' + email + '\" ] }'
        )
        
        return {
            "statusCode": "200",
            "message":"Registration successful. Verification code sent successfully to " + event['body-json']['username'],
        }
    except: 
        return {
            "statusCode": "404",
            "message":"Registration failed or user already exists.",
        }

def confirm_register(event, context):
    
    client = boto3.client('cognito-idp', region_name=os.getenv('COGNITO_REGION_NAME'))
    snsClient = boto3.client('sns')
    try:
        client = boto3.client('cognito-idp', region_name=os.getenv('COGNITO_REGION_NAME'))
        response = client.confirm_sign_up(
            ClientId=os.getenv('COGNITO_USER_CLIENT_ID'),
            Username=event['body-json']['username'],
            ConfirmationCode=event['body-json']['code']
        )
        
        email = event['body-json']['username']
        responseSns = snsClient.publish(
        TopicArn='arn:aws:sns:us-east-1:359996502019:SNSRegisterConfirmation',
        Message='Verification Successfull',
        Subject='Success',
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
            "message": "Email verified successfully.",
        }

    except botocore.exceptions.ClientError as err:
        if err.response["Error"]["Code"] == "UsernameExistsException":
            return{
                "statusCode":"201",
                "message": "User already exists."
            }
        elif err.response["Error"]["Code"] == "CodeMismatchException":
            return{
                "statusCode":"202",
                "message": "Code does not match."
            }
    except:
        return{
            "statusCode": "203",
            "message": "Something went wrong."
        }
            

def login(event, context):
    client = boto3.client('cognito-idp', region_name=os.getenv('COGNITO_REGION_NAME'))
    try:
            
        
        response = client.initiate_auth(
            ClientId=os.getenv('COGNITO_USER_CLIENT_ID'),
            AuthFlow='USER_PASSWORD_AUTH',
            AuthParameters={
                'USERNAME': event['body-json']['username'],
                'PASSWORD': event['body-json']['password'],
            }
        )
        print(response)
    
        client = boto3.client('cognito-idp', region_name=os.getenv('COGNITO_REGION_NAME'))
        userDetails = client.get_user(
        AccessToken=response['AuthenticationResult']['AccessToken']
        )
        
        print(userDetails)
        subattributes = None
        for attribute in userDetails['UserAttributes']:
            if attribute['Name'] == 'sub':
                 subattributes = attribute['Value']
            break
    
        print('UserDetails', subattributes)
        details = []
        for i in userDetails['UserAttributes']:
            details.append(i["Value"])

        return {
            "statusCode": "200",
            "message":"Login Sucessful",
            "username": details[0],
            "email": details[6],
            "name": details[3] + ' ' + details[5],
            "dob": details[1],
            "profile": details[4],
            "email_verified": details[2],
        }
    
    except:
        return {
            "statusCode": "401",
            "message":"Login failed"
        }
        

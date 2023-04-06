import os
import base64
import csv
from datetime import datetime
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

# Ask for the search query
search_query = input("Enter the search query: ")

# Set up the Gmail API client
creds = Credentials.from_authorized_user_file('token.json', ['https://www.googleapis.com/auth/gmail.readonly'])
service = build('gmail', 'v1', credentials=creds)

# Search for the email using the query provided
try:
    response = service.users().messages().list(userId='me', q=search_query).execute()
    messages = response['messages']
    print(f"Total results: {len(messages)}")

    for message in messages:
        msg = service.users().messages().get(userId='me', id=message['id']).execute()

        # Get the relevant information (to, from, subject, body) from the email
        to = [header['value'] for header in msg['payload']['headers'] if header['name'] == 'To'][0]
        from_email = [header['value'] for header in msg['payload']['headers'] if header['name'] == 'From'][0]
        subject = [header['value'] for header in msg['payload']['headers'] if header['name'] == 'Subject']
        subject = subject[0] if subject else datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        body = msg['payload']['body'].get('data', '')
        if body:
            decoded_body = base64.urlsafe_b64decode(body).decode('utf-8')
        else:
            parts = msg['payload']['parts']
            for part in parts:
                if part['mimePartType'] == 'text/plain':
                    decoded_body = base64.urlsafe_b64decode(part['body']['data']).decode('utf-8')
                    break

        # Output the information to a CSV file with the subject or timestamp as the title
        filename = f"{subject}.csv"
        with open(filename, mode='a', newline='') as file:
            writer = csv.writer(file)
            writer.writerow([to, from_email, subject, decoded_body])
except HttpError as error:
    print(f"An error occurred: {error}")

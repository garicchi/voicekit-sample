from google.assistant.library import Assistant
import json
import google.oauth2.credentials
import argparse
import os

def get_device_id():
    credentials_path = os.path.join(os.path.expanduser('~/.config'),'google-oauthlib-tool','credentials.json')
    with open(credentials_path, 'r') as f:
        credentials = google.oauth2.credentials.Credentials(token=None,**json.load(f))

    parser = argparse.ArgumentParser(formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument('--device_model_id', type=str,metavar='DEVICE_MODEL_ID',
                        required=True,help='The device model ID registered with Google')
    args = parser.parse_args()
    with Assistant(credentials, args.device_model_id) as assistant:
        events = assistant.start()
        device_id = assistant.device_id
    return device_id
                

if __name__=='__main__':
    device_id = get_device_id()
    print(device_id)

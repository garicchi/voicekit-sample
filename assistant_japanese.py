# -*- coding: utf-8 -*-
import aiy.audio
import aiy.cloudspeech
import aiy.voicehat
import aiy.i18n
import googlesamples.assistant.grpc.pushtotalk as pushtotalk
import click
import os
import sys
import uuid
import grpc
import json
import logging
import google.auth.transport.grpc
import google.auth.transport.requests
import google.oauth2.credentials
from google.assistant.embedded.v1alpha2 import (
    embedded_assistant_pb2,
    embedded_assistant_pb2_grpc
)
from googlesamples.assistant.grpc import (
        assistant_helpers,
        audio_helpers,
        device_helpers
)

from googlesamples.assistant.grpc.pushtotalk import SampleAssistant

ASSISTANT_API_ENDPOINT = 'embeddedassistant.googleapis.com'
END_OF_UTTERANCE = embedded_assistant_pb2.AssistResponse.END_OF_UTTERANCE
DIALOG_FOLLOW_ON = embedded_assistant_pb2.DialogStateOut.DIALOG_FOLLOW_ON
CLOSE_MICROPHONE = embedded_assistant_pb2.DialogStateOut.CLOSE_MICROPHONE
DEFAULT_GRPC_DEADLINE = 60 * 3 + 5
device_config=os.path.join(click.get_app_dir('googlesamples-assistant'),'device_config.json')
verbose=False

def main():
    device_model_id='{ your device model id }'
    project_id='{ your project id }'
    lang='ja-JP'
    logging.basicConfig(level=logging.DEBUG if verbose else logging.INFO)
    
    button = aiy.voicehat.get_button()
    led = aiy.voicehat.get_led()

    credentials = os.path.join(click.get_app_dir('google-oauthlib-tool'),'credentials.json')
    with open(credentials, 'r') as f:
            credentials = google.oauth2.credentials.Credentials(token=None,
                                                                **json.load(f))
            http_request = google.auth.transport.requests.Request()
            credentials.refresh(http_request)
    
    # Create an authorized gRPC channel.
    grpc_channel = google.auth.transport.grpc.secure_authorized_channel(
        credentials, http_request, ASSISTANT_API_ENDPOINT)
    audio_device = None
    # Configure audio source and sink.
    audio_source = audio_device = (
            audio_device or audio_helpers.SoundDeviceStream(
                sample_rate=audio_helpers.DEFAULT_AUDIO_SAMPLE_RATE,
                sample_width=audio_helpers.DEFAULT_AUDIO_SAMPLE_WIDTH,
                block_size=audio_helpers.DEFAULT_AUDIO_DEVICE_BLOCK_SIZE,
                flush_size=audio_helpers.DEFAULT_AUDIO_DEVICE_FLUSH_SIZE
            )
        )
    audio_sink = audio_device = (
            audio_device or audio_helpers.SoundDeviceStream(
                sample_rate=audio_helpers.DEFAULT_AUDIO_SAMPLE_RATE,
                sample_width=audio_helpers.DEFAULT_AUDIO_SAMPLE_WIDTH,
                block_size=audio_helpers.DEFAULT_AUDIO_DEVICE_BLOCK_SIZE,
                flush_size=audio_helpers.DEFAULT_AUDIO_DEVICE_FLUSH_SIZE
            )
        ) 
    
    # Create conversation stream with the given audio source and sink.
    conversation_stream = audio_helpers.ConversationStream(
        source=audio_source,
        sink=audio_sink,
        iter_size=audio_helpers.DEFAULT_AUDIO_ITER_SIZE,
        sample_width=audio_helpers.DEFAULT_AUDIO_SAMPLE_WIDTH,
    )

    device_id = None
    device_handler = device_helpers.DeviceRequestHandler(device_id)
    """
    @device_handler.command('action.devices.commands.OnOff')
    def onoff(on):
        if on:
            logging.info('Turning device on')
        else:
            logging.info('Turning device off')
    """
    if not device_id or not device_model_id:
        try:
            with open(device_config) as f:
                device = json.load(f)
                device_id = device['id']
                device_model_id = device['model_id']
        except Exception as e:
            
            if not device_model_id:
                sys.exit(-1)
            if not project_id:
                sys.exit(-1)
            device_base_url = (
                'https://%s/v1alpha2/projects/%s/devices' % (ASSISTANT_API_ENDPOINT,
                                                             project_id)
            )
            device_id = str(uuid.uuid1())
            payload = {
                'id': device_id,
                'model_id': device_model_id
            }
            session = google.auth.transport.requests.AuthorizedSession(
                credentials
            )
            r = session.post(device_base_url, data=json.dumps(payload))
            if r.status_code != 200:
                sys.exit(-1)
            os.makedirs(os.path.dirname(device_config), exist_ok=True)
            with open(device_config, 'w') as f:
                json.dump(payload, f)

    with SampleAssistant(lang, device_model_id, device_id,
                         conversation_stream,
                         grpc_channel, DEFAULT_GRPC_DEADLINE,
                         device_handler) as assistant:
        
        
        assistant.assist()

        wait_for_user_trigger = True
        while True:
            if wait_for_user_trigger:
                print('Press the button and speak')
                button.wait_for_press()
            continue_conversation = assistant.assist()
            # wait for user trigger if there is no follow-up turn in
            # the conversation.
            wait_for_user_trigger = not continue_conversation
            
if __name__ == '__main__':
    main()

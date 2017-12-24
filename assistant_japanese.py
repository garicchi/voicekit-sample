# -*- coding: utf-8 -*-

# original program is here https://github.com/googlesamples/assistant-sdk-python/blob/master/google-assistant-sdk/googlesamples/assistant/grpc/pushtotalk.py
# changed point --> "implementation SampleAssistant in pushtotalk.py"

# Copyright (C) 2017 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
import aiy.audio
import aiy.cloudspeech
import aiy.voicehat
import aiy.i18n
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


# Google Assistantデバイスの初期設定
def initialize(device_model_id=None,project_id=None,lang='ja-JP'):
    # ログ設定
    logging.basicConfig(level=logging.INFO)

    # 認証情報を取得する
    credentials = os.path.join(
        click.get_app_dir('google-oauthlib-tool'),
        'credentials.json'
    )
    with open(credentials, 'r') as f:
        credentials = google.oauth2.credentials.Credentials(token=None,**json.load(f))
        http_request = google.auth.transport.requests.Request()
        credentials.refresh(http_request)
            
    # デバイス設定の取得
    device_config=os.path.join(
        click.get_app_dir('googlesamples-assistant'),
        'device_config.json'
    )
    
    # gRPCチャンネルの取得
    ASSISTANT_API_ENDPOINT='embeddedassistant.googleapis.com'
    grpc_channel = google.auth.transport.grpc.secure_authorized_channel(
        credentials, http_request, ASSISTANT_API_ENDPOINT
    )

    # オーディオデバイスの取得と設定
    audio_device = None
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
    
    # conversation streamの作成
    conversation_stream = audio_helpers.ConversationStream(
        source=audio_source,
        sink=audio_sink,
        iter_size=audio_helpers.DEFAULT_AUDIO_ITER_SIZE,
        sample_width=audio_helpers.DEFAULT_AUDIO_SAMPLE_WIDTH,
    )

    # device idの取得
    device_id = None
    device_handler = device_helpers.DeviceRequestHandler(device_id)

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
                'https://%s/v1alpha2/projects/%s/devices' % (
                    ASSISTANT_API_ENDPOINT,
                    project_id
                )
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
                
    return device_model_id,device_id,conversation_stream,grpc_channel,device_handler


def main():
    # 自身の情報に置き換える
    device_model_id='{ your device model id }'
    project_id='{ your project id }'
    lang='ja-JP'
    DEFAULT_GRPC_DEADLINE = 60 * 3 + 5

    button = aiy.voicehat.get_button()
    led = aiy.voicehat.get_led()
    # 初期設定
    device_model_id,device_id,conversation_stream,grpc_channel,device_handler = initialize(device_model_id,project_id,lang)
    
    # pushtotalk.pyのSampleAssistantを使用する
    with SampleAssistant(lang, device_model_id, device_id,
                         conversation_stream,
                         grpc_channel, DEFAULT_GRPC_DEADLINE,
                         device_handler) as assistant:

        continue_talk = False
        while True:
            led.set_state(aiy.voicehat.LED.OFF)
            # 会話が前回からつながっているならボタン入力をスキップ
            if not continue_talk:
                print('\n*********************\n')
                print('ボタンを押して話してください')
                print('\n*********************\n')
                button.wait_for_press()
                
            led.set_state(aiy.voicehat.LED.ON)
            continue_talk = assistant.assist()
            
if __name__ == '__main__':
    main()

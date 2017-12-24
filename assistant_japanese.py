# -*- coding: utf-8 -*-
import aiy.audio
import aiy.cloudspeech
import aiy.voicehat
import aiy.i18n
import sample_grpc.pushtotalk
import sys

device_model_id='{ your device model id }'
project_id='{ your project id }'

def main():
    
    button = aiy.voicehat.get_button()
    led = aiy.voicehat.get_led()
    sys.argv.append('--device-model-id')
    sys.argv.append(device_model_id)
    sys.argv.append('--project-id')
    sys.argv.append(project_id)
    sys.argv.append('--lang')
    sys.argv.append('ja-JP')
    sys.argv.append('--once')
    
    while True:
        print('Press the button and speak')
        button.wait_for_press()
        sample_grpc.pushtotalk.main()

if __name__ == '__main__':
    main()

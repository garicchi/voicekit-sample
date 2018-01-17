# -*- coding: utf-8 -*-
import aiy.audio
import aiy.cloudspeech
import aiy.voicehat
import aiy.i18n
from pyjtalk.pyjtalk import PyJtalk

def main():
    # 言語設定を日本語にする
    aiy.i18n.set_language_code('ja-JP')
    recognizer = aiy.cloudspeech.get_recognizer()
    jtalk = PyJtalk()

    button = aiy.voicehat.get_button()
    led = aiy.voicehat.get_led()
    aiy.audio.get_recorder().start()

    while True:
        print('Press the button and speak')
        button.wait_for_press()
        jtalk.say('ご用件をどうぞ')
        print('Listening...')
        text = recognizer.recognize()
        if text is None:
            print('Sorry, I did not hear you.')
        else:
            print('You said "', text, '"')
            if '点灯' in text:
                jtalk.say('ライトをつけました')
                led.set_state(aiy.voicehat.LED.ON)
            elif '終了' in text:
                break


if __name__ == '__main__':
    main()

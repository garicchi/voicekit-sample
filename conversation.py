# -*- coding: utf-8 -*-
import aiy.audio
import aiy.cloudspeech
import aiy.voicehat
import aiy.i18n
import urllib.request as request
import json
from pyjtalk.pyjtalk import PyJtalk

docomo_key = '{{ your docomo api key is here }}'

def talk(key,speech,context=''):
    headers = {
        'Content-Type':'application/json'
    }
    body = {
        'utt':speech,
        'context':context,
        'mode':'dialog'
    }
    content = json.dumps(body,ensure_ascii=False).encode('utf-8')
    url = 'https://api.apigw.smt.docomo.ne.jp/dialogue/v1/dialogue?APIKEY=%s'%(key)
    req = request.Request(url,content,headers,method='POST')
    with request.urlopen(req) as res:
        b = res.read().decode('utf-8')
        c = json.loads(b)
    return c

def main():
    # 言語設定を日本語にする
    aiy.i18n.set_language_code('ja-JP')
    recognizer = aiy.cloudspeech.get_recognizer()
    jtalk = PyJtalk()
    button = aiy.voicehat.get_button()
    led = aiy.voicehat.get_led()
    aiy.audio.get_recorder().start()

    context = ''
    while True:
        led.set_state(aiy.voicehat.LED.BEACON_DARK)
        print('\nボタンを押してください')
        button.wait_for_press()
        led.set_state(aiy.voicehat.LED.ON)
        print('話してください\n')
        text = recognizer.recognize()
        led.set_state(aiy.voicehat.LED.BLINK)
        print('[あなた]%s'%text)
        res = talk(docomo_key,text,context)
        print('[システム]%s'%res['utt'])
        jtalk.say(res['yomi'])
        context = res['context']



if __name__ == '__main__':
    main()

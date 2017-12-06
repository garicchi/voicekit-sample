# -*- coding: utf-8 -*-
import aiy.audio
import aiy.cloudspeech
import aiy.voicehat
import aiy.i18n
import urllib.request as request
import json

event_name = 'aiy_email'
webhook_key = '{{ your key is here }}'

def post_ifttt(event_name,key,values):
    headers = {
        'Content-Type':'application/json'
    }
    content = json.dumps(values,ensure_ascii=False).encode('utf-8')
    url = 'https://maker.ifttt.com/trigger/%s/with/key/%s'%(event_name,key)
    req = request.Request(url,content,headers,method='POST')
    with request.urlopen(req) as res:
        b = res.read().decode('utf-8')
        print(b)

def main():
    # 言語設定を日本語にする
    aiy.i18n.set_language_code('ja-JP')
    recognizer = aiy.cloudspeech.get_recognizer()

    button = aiy.voicehat.get_button()
    led = aiy.voicehat.get_led()
    aiy.audio.get_recorder().start()

    while True:
        print('Press the button and speak')
        button.wait_for_press()
        aiy.audio.say('ご用件をどうぞ')
        text = recognizer.recognize()
        if text is None:
            print('聞き取り失敗しました')
        else:
            if 'メール' in text:
                aiy.audio.say('本文をどうぞ')
                text = recognizer.recognize()
                post_ifttt(
                    event_name,
                    webhook_key,
                    {
                        'value1':text
                    }
                )
                aiy.audio.say('メールをおくりました')
            elif '終了' in text:
                break


if __name__ == '__main__':
    main()

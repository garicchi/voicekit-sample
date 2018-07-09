import requests
import os
import json
import aiy.audio
import aiy.cloudspeech
import aiy.voicehat
import aiy.i18n
from pyjtalk.pyjtalk import PyJtalk

docomo_key = "{ docomo api key }"


def registration(config_path,key):
    regist = "https://api.apigw.smt.docomo.ne.jp/naturalChatting/v1/registration?APIKEY={key}"\
        .format(key=key)
    data = {
        "botId": "Chatting",
        "appKind": "Smart Phone"
    }
    res = requests.post(regist, json=data)
    res_json = res.json()

    with open(config_path, "w") as f:
        json.dump(res_json, f)

def conversation(key,app_id,speech):
    url = "https://api.apigw.smt.docomo.ne.jp/naturalChatting/v1/dialogue?APIKEY={key}" \
        .format(key=key)
    data = {
        "botId": "Chatting",
        "appId": app_id,
        "voiceText":speech,
        "language":"ja-JP"
    }
    res = requests.post(url, json=data)
    res_json = res.json()
    return res_json["systemText"]["utterance"]

def main():
    cache = os.path.join(os.environ["HOME"],".cache")
    dialog = os.path.join(cache,"dialog.json")
    if not os.path.exists(cache):
        os.mkdir(cache)

    if not os.path.exists(dialog):
        registration(dialog,docomo_key)

    with open(dialog,"r") as f:
        config = json.load(f)

    app_id = config["appId"]

    # 言語設定を日本語にする
    aiy.i18n.set_language_code('ja-JP')
    recognizer = aiy.cloudspeech.get_recognizer()
    jtalk = PyJtalk()
    button = aiy.voicehat.get_button()
    led = aiy.voicehat.get_led()
    aiy.audio.get_recorder().start()

    while True:
        led.set_state(aiy.voicehat.LED.BEACON_DARK)
        print('\nボタンを押してください')
        button.wait_for_press()
        led.set_state(aiy.voicehat.LED.ON)
        print('話してください\n')
        text = recognizer.recognize()
        led.set_state(aiy.voicehat.LED.BLINK)
        print('[あなた]%s' % text)
        res = conversation(docomo_key, app_id, text)
        print('[システム]%s' % res)
        jtalk.say(res)

if __name__ == "__main__":
    main()

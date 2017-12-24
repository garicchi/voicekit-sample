# voicekit-sample
samples for google aiy voice kit

## assistant_japanese.py
Start dev termialを立ち上げ、google-assistant-sdkのアップグレードを行う

```sh
pip install --upgrade google-assistant-sdk[samples]
```
[https://developers.google.com/assistant/sdk/guides/service/python/](https://developers.google.com/assistant/sdk/guides/service/python/)を参考にAssistant SDKの設定を進めていく

API&serviceの認証情報をassistant.jsonとしてホームフォルダに保存している人はスキップ
google cloud platformのコンソールからAPI&ServiceのOAuth認証情報(json)を再度ダウンロードし、ホームフォルダに保存
```sh
mv ~/Downloads/client_secret_* ~
```

OAuthLibToolのアップデートを行う

```sh
pip install --upgrade google-auth-oauthlib[tool]
```

OAuth認証で認証を行う
```sh
google-oauthlib-tool --scope https://www.googleapis.com/auth/assistant-sdk-prototype --save --headless --client-secrets ~/assistant.json
# 表示されたURLをブラウザに貼り付けて開き、表示されたキーコードをターミナルのEnter the autorization codeの部分に貼り付ける
```

デバイスの登録を行う
```sh
# ホームフォルダへ移動
cd ~
# デバイス登録
googlesamples-assistant-devicetool register-model --manufacturer 'developer' --product-name 'voicekit-sample' --type LIGHT --model {  your project id }l
# 登録したデバイスの確認
googlesamples-assistant-devicetool list --model
```

pushtotalkサンプルの実行
```sh
googlesamples-assistant-pushtotalk --project-id { your device model id } --device-model-id {  your project id } --lang 'ja-JP'
# Enterを押してassistantに話す
```

VoiceKitのサンプルをダウンロード
```sh
cd ~/AIY-voice-kit-python
wget https://raw.githubusercontent.com/garicchi/voicekit-sample/master/assistant_japanese.py -O src/assistant_japanese.py
```

project-idとdevice-model-idの入力

```sh
nano src/assistant_japanese.py
# { your device model id }と{  your project id }をそれぞれ自分のものに置き換える
```

VoiceKitサンプルの実行

```sh
python src/assistant_japanese.py
# VoiceKitのプッシュボタンを押してassistantに発話
```

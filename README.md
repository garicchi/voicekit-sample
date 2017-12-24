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
googlesamples-assistant-devicetool register-model --manufacturer 'developer' --product-name 'voicekit-sample' --type LIGHT --model voicekit-model
# 登録したデバイスの確認
googlesamples-assistant-devicetool list --model
```

pushtotalkサンプルの実行
```sh
googlesamples-assistant-pushtotalk --project-id aiyproject2-189517 --device-model-id voicekit-model --lang 'ja-JP'
# Enterを押してassistantに話す
```

# register model and device

download client secret as JSON file from GCP console

move home folder (keep file name)
```sh
mv ~/Downloads/client_secret_* ~
```

oauth certification
```sh
google-oauthlib-tool --scope https://www.googleapis.com/auth/assistant-sdk-prototype --save --headless --client-secrets { your client secret file }
```

register model

```sh
cd ~
googlesamples-assistant-devicetool register-model --manufacturer 'developer' --product-name 'voicekit-sample' --type LIGHT --model { your model id }
```

confirm model registering
```sh
googlesamples-assistant-devicetool list --model
```

# push to talk sample
```sh
cd ~/AIY-voice-kit-python
wget https://raw.githubusercontent.com/garicchi/voicekit-sample/master/assistant_japanese.py -O src/assistant_japanese.py
```

```sh
nano src/assistant_japanese.py
# { your device model id }と{  your project id }をそれぞれ自分のものに置き換える
```

```sh
cp -R ~/AIY-voice-kit-python/env/lib/python3.4/site-packages/googlesamples/ ~/AIY-voice-kit-python/src/
```

```sh
python src/assistant_japanese.py
```

#!/bin/bash

function setup(){
    run "cd ~"
    section "setupを実行します"
    section "aptパッケージをアップデートします"
    run "cd /var/cache/apt/archives&&sudo dpkg -i --force-overwrite python3-scrollphathd_1.1.0_all.deb"
    run "sudo apt-get -y update&&sudo apt-get -y upgrade"
    section "google asssitant sdkをアップデートします"
    echo "参考URL[https://developers.google.com/assistant/sdk/guides/library/python/embed/install-sample]"
    section "必要なaptパッケージをインストールします"
    run "sudo apt-get install -y portaudio19-dev libffi-dev libssl-dev"

    section "google-assistant-library pythonパッケージをアップデートします"
    echo "現在のgoogle-assistant-libraryのバージョンを表示します"
    run "pip list|grep google-assistant-library"
    run "pip install -U google-assistant-library"
    echo "google-assistant libraryのアップデート後のバージョンを表示します"
    run "pip list|grep google-assistant-library"

    section "google-assistant-sdk pythonパッケージをアップデートします"
    echo "現在のgoogle-assistant-sdkのバージョンを表示します"
    run "pip list|grep google-assistant-sdk"
    run "pip install -U google-assistant-sdk[samples]"
    echo "google-assistant sdkのアップデート後のバージョンは以下です"
    run "pip list|grep google-assistant-sdk"

    section "google-auth-oauthlib pythonパッケージをアップデートします"
    echo "現在のgoogle-auth-oauthlibのバージョンを表示します"
    run "pip list|grep google-auth-oauthlib"
    run "pip install -U google-auth-oauthlib[tool]"
    echo "google-auth-oauthlibのアップデート後のバージョンを表示します"
    run "pip list|grep google-auth-oauthlib"

    section "assistant libraryを利用するためにGCPのOAuth認証情報を作成します"
    echo "GCPのコンソール[https://console.cloud.google.com]をラズパイのブラウザで開いてください"
    wait
    echo "新しくプロジェクトを作成してください(すでに作成しているのであれば大丈夫です)"
    wait
    echo "API & Services -> 認証情報の項目を開いてください"
    echo "OAuth同意画面の項目から[ユーザーに表示するサービス名]に適当な名前を入力して保存を押します"
    wait
    echo "[認証情報]のタブをクリックします"
    echo "[認証情報を作成]をクリックし、[OAuthクライアントID]を選択します"
    echo "アプリケーションの種類で[その他]を選択し、名前に適当な名前を入力し、[作成]ボタンを押します"
    wait
    echo "API & Services -> ライブラリをクリックし、検索ボックスにgoogle assistantを入力し、Google Assistant APIをクリック、[有効にする]ボタンを押します"
    wait
    echo "作成されたOAuthクライアントの認証情報JSONをダウンロードします"
    wait
    secret=`ls ~/Downloads/client_secret_*|head -n 1`
    run "cp $secret ~/assistant.json"
    run "cp $secret ~"
    echo "認証を行います。URLが表示されたらブラウザに張り付けてアクセスし、表示された認証コードをターミナルに張り付けてください"
    run "google-oauthlib-tool --scope https://www.googleapis.com/auth/assistant-sdk-prototype --save --headless --client-secrets $secret"

    section "cloud speechを利用するためにGCPのサービスアカウント認証情報を作成します"
    echo "GCPのコンソール[https://console.cloud.google.com]をラズパイのブラウザで開いてください"
    wait
    echo "API & Services -> 認証情報の項目を開いてください"
    echo "[認証情報]のタブをクリックします"
    echo "[認証情報を作成]をクリックし、[サービスアカウントキー]を選択します"
    echo "[サービスアカウント名]に適当な名前を入力し、[役割]はProject>閲覧者を選択、キータイプはJSONを選択し[作成]をクリックします"
    wait
    echo "API & Services -> ライブラリをクリックし、検索ボックスにcloud speech apiを入力し、Google Cloud Speech APIをクリック、[有効にする]ボタンを押します"
    echo "認証情報がダウンロードされます"
    wait
    secret=`ls -t ~/Downloads/|head -n 1`
    run "$secret ~/cloud_speech.json"
    
    section "モデルの登録を行います"
    echo "manufacturerを入力してください(default) developer"
    read manufacturer
    if [ "$manufacturer" == "" ]; then
	manufacturer='developer'
    fi
    echo "product-nameを入力してください(default) my-voicekit-assistant"
    read productname
    if [ "$productname" == "" ]; then
	productname='my-voicekit-assistant'
    fi

    echo "model名を入力してくださ( {GCPのProjectname}-{model name}が推奨されています)"
    read model

    run "googlesamples-assistant-devicetool register-model --manufacturer "$manufacturer" --product-name "$productname" --type LIGHT --trait action.devices.traits.OnOff --model $model"
    echo "モデルの登録が完了しました"
    echo "現在登録されているモデル一覧を表示します"
    run "googlesamples-assistant-devicetool list --model"

    section "デバイスの登録を行います"
    echo "デバイス名を入力してください"
    read device
    run "googlesamples-assistant-devicetool register-device --client-type LIBRARY --model $model --device $device"
    echo "デバイスの登録が完了しました"
    echo "現在登録されているデバイス一覧を表示します"
    run "googlesamples-assistant-devicetool list --device"

    section "登録したデバイスの日本語設定を行います"
    echo "スマートフォンからGoogleAssistantアプリを起動し、右上の青いボタンを押します"
    echo "右上の[設定]を押します"
    echo "デバイスの項目に登録したデバイスである[$device]が表示されているので選択し"
    echo "アシスタントの言語を[日本語(日本)]に変更します"
    wait
    
    section "AIYProjectのライブラリコードを更新します"
    run "cd ~/AIY-projects-python"
    run "git pull"
    run "cd ~"

    section "音声合成を日本語に対応させます"
    run "sudo apt-get install -y open-jtalk-mecab-naist-jdic hts-voice-nitech-jp-atr503-m001 openjtalk"
    run "pip install pyjtalk"

    section "サンプルコードをダウンロードします"
    run "wget -P ~/AIY-projects-python/src/examples/voice/ https://raw.githubusercontent.com/garicchi/voicekit-sample/develop/japanese_demo.py"
    run "wget -P ~/AIY-projects-python/src/examples/voice/ https://raw.githubusercontent.com/garicchi/voicekit-sample/develop/ifttt_email.py"
    run "wget -P ~/AIY-projects-python/src/examples/voice/ https://raw.githubusercontent.com/garicchi/voicekit-sample/develop/conversation.py"
    run "wget -P ~/AIY-projects-python/src/examples/voice/ https://raw.githubusercontent.com/garicchi/voicekit-sample/develop/assistant_japanese.py"
    section "VoiceKitのセットアップが完了しました"
    
}

function wait(){
    echo "完了したらEnterを押してください"
    read input
    
}

function section(){
    echo ""
    echo "*******************************"
    echo $1
    echo "*******************************"
    echo ""
}

function run(){
    echo ""
    echo "*****以下のコマンドを実行します*********"
    echo ""
    echo $1
    echo ""
    echo "***************************************"
    echo ""
    eval $1
}

if [ "`python --version |& cut -d . -f 1`" = "Python 2" ]; then
    echo "Start dev terminalで実行してください"
    exit 1
fi

while true
do
	echo ""
	echo "------ コマンドを入力してください -------"
	commands=("[setup]--setup_voice_kit" "[exit]--finish_this_script")
	for c in ${commands[@]}; do
		echo $c
	done
	read command
	echo "you input "$command
	case "$command" in
	    "setup" ) setup ;;
	    "exit" ) break ;;
	esac

done
echo "終了します"

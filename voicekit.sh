#!/bin/bash

COLOR_STEP="\e[34;1m"
COLOR_INPUT="\e[31;5m"
COLOR_CMD="\e[32m"
COLOR_END="\e[m"

function setup(){
    run "cd ~"
    step "setupを実行します"
    step "aptパッケージをアップデートします"
    run "cd /var/cache/apt/archives&&sudo dpkg -i --force-overwrite python3-scrollphathd_1.1.0_all.deb"
    run "sudo apt-get -y update&&sudo apt-get -y upgrade"
    step "google asssitant sdkをアップデートします"
    echo "参考URL[https://developers.google.com/assistant/sdk/guides/library/python/embed/install-sample]"
    step "必要なaptパッケージをインストールします"
    run "sudo apt-get install -y portaudio19-dev libffi-dev libssl-dev"
    run "cd ~"
    step "google-assistant-library pythonパッケージをアップデートします"
    echo "現在のgoogle-assistant-libraryのバージョンを表示します"
    run "pip list|grep google-assistant-library"
    run "pip install -U google-assistant-library"
    echo "google-assistant libraryのアップデート後のバージョンを表示します"
    run "pip list|grep google-assistant-library"
    
    step "google-assistant-sdk pythonパッケージをアップデートします"
    echo "現在のgoogle-assistant-sdkのバージョンを表示します"
    run "pip list|grep google-assistant-sdk"
    run "pip install -U google-assistant-sdk[samples]"
    echo "google-assistant sdkのアップデート後のバージョンは以下です"
    run "pip list|grep google-assistant-sdk"
    
    step "google-auth-oauthlib pythonパッケージをアップデートします"
    echo "現在のgoogle-auth-oauthlibのバージョンを表示します"
    run "pip list|grep google-auth-oauthlib"
    run "pip install -U google-auth-oauthlib[tool]"
    echo "google-auth-oauthlibのアップデート後のバージョンを表示します"
    run "pip list|grep google-auth-oauthlib"

    run "rm ~/Downloads/*.json"
    step "assistant libraryを利用するためにGCPのOAuth認証情報を作成します"
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
    echo "ダウンロード用のボタンを押し、作成されたOAuthクライアントの認証情報JSONをダウンロードしてください"
    wait
    secret=`ls ~/Downloads/client_secret_*|head -n 1`
    run "cp $secret ~/assistant.json"
    run "cp $secret ~"
    secret=`ls ~/client_secret_*|head -n 1`
    echo "認証を行います。URLが表示されたらブラウザに張り付けてアクセスし、表示された認証コードをターミナルに張り付けてください"
    run "google-oauthlib-tool --scope https://www.googleapis.com/auth/assistant-sdk-prototype --save --headless --client-secrets $secret"

    step "cloud speechを利用するためにGCPのサービスアカウント認証情報を作成します"
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
    secret=`ls -t ~/Downloads/*.json|head -n 1`
    run "cp $secret ~/cloud_speech.json"
    
    step "モデルの登録を行います"
    input_msg "manufacturerを入力してください(default) developer"
    read manufacturer
    if [ "$manufacturer" == "" ]; then
	manufacturer='developer'
    fi
    input_msg "product-nameを入力してください(default) my-voicekit-assistant"
    read productname
    if [ "$productname" == "" ]; then
	productname='my-voicekit-assistant'
    fi

    input_msg "model名を入力してください( {GCPのProjectname}-{model name}が推奨されています)"
    read model

    run "googlesamples-assistant-devicetool register-model --manufacturer "$manufacturer" --product-name "$productname" --type LIGHT --trait action.devices.traits.OnOff --model $model"
    echo "モデルの登録が完了しました"
    echo "現在登録されているモデル一覧を表示します"
    run "googlesamples-assistant-devicetool list --model"

    step "デバイスの登録を行います"
    echo "デバイスIDを取得します"
    run "rm device_id.py"
    run "wget https://raw.githubusercontent.com/garicchi/voicekit-sample/develop/device_id.py"
    cmd="python device_id.py --device_model_id $model"
    echo "$cmd を実行します"
    device_id=`$cmd`
    echo "device_idは$device_idです"
    run "googlesamples-assistant-devicetool register-device --client-type LIBRARY --model $model --device $device_id"
    echo "デバイスの登録が完了しました"
    echo "現在登録されているデバイス一覧を表示します"
    run "googlesamples-assistant-devicetool list --device"

    step "スマートフォンを用いて登録したデバイスの日本語設定を行います"
    echo "スマートフォンからGoogleAssistantアプリを起動し、右上の青いボタンを押します"
    echo "右上の[設定]を押します"
    echo "デバイスの項目に登録したデバイスである[$productname]が表示されているので選択し"
    echo "アシスタントの言語を[日本語(日本)]に変更します"
    echo "[https://github.com/garicchi/voicekit-sample/blob/develop/set_japanese.md]に解説があるので参考にしてください"
    wait
    
    step "AIYProjectのライブラリコードを更新します"
    run "cd ~/AIY-projects-python"
    run "git pull --all"
    run "cd ~"

    step "音声合成を日本語に対応させます"
    run "sudo apt-get install -y open-jtalk-mecab-naist-jdic hts-voice-nitech-jp-atr503-m001 open-jtalk"
    run "cd ~"
    run "pip install pyjtalk"

    step "サンプルコードをダウンロードします"
    run "rm ~/AIY-projects-python/src/examples/voice/cloud_speech_ja.py"
    run "wget -P ~/AIY-projects-python/src/examples/voice/ https://raw.githubusercontent.com/garicchi/voicekit-sample/develop/cloud_speech_ja.py"
    run "rm ~/AIY-projects-python/src/examples/voice/ifttt_email.py"
    run "wget -P ~/AIY-projects-python/src/examples/voice/ https://raw.githubusercontent.com/garicchi/voicekit-sample/develop/ifttt_email.py"
    run "rm ~/AIY-projects-python/src/examples/voice/conversation.py"
    run "wget -P ~/AIY-projects-python/src/examples/voice/ https://raw.githubusercontent.com/garicchi/voicekit-sample/develop/conversation.py"
    run "rm ~/AIY-projects-python/src/examples/voice/assistant_push_demo.py"
    run "wget -P ~/AIY-projects-python/src/examples/voice/ https://raw.githubusercontent.com/garicchi/voicekit-sample/develop/assistant_push_demo.py"
    run "rm ~/AIY-projects-python/src/examples/voice/assistant_library_demo_v2.py"
    run "wget -O ~/AIY-projects-python/src/examples/voice/assistant_library_demo_v2.py https://raw.githubusercontent.com/google/aiyprojects-raspbian/voicekit/src/assistant_library_demo.py"
    run "rm ~/AIY-projects-python/src/aiy/assistant/device_helpers.py"
    run "wget -O ~/AIY-projects-python/src/aiy/assistant/device_helpers.py https://raw.githubusercontent.com/google/aiyprojects-raspbian/voicekit/src/aiy/assistant/device_helpers.py"
	step "サウンド機器のチェックと初期化を行います"
	run "python ~/AIY-projects-python/checkpoints/check_audio.py"

	run "cd ~/AIY-projects-python"
	step "VoiceKitのセットアップが完了しました"
}

function assistant_library_demo(){
    step "assistant_library_demo.pyを実行します"
    echo -e "${COLOR_INPUT}assistant_library_demoは現在日本語の「オッケーグーグル」に対応しきれていません。反応しない場合は「オッケーｺﾞｰｺﾞｩ」の
ように英語っぽく話しかけてみてください${COLOR_END}"
    run "python ~/AIY-projects-python/src/examples/voice/assistant_library_demo_v2.py"
}

function assistant_push_demo(){
    step "assistant_push_demo.pyを実行します"
    run "python ~/AIY-projects-python/src/examples/voice/assistant_push_demo.py"
}

function cloud_speech(){
    step "cloud_speech.pyを実行します"
    run "python ~/AIY-projects-python/src/examples/voice/cloud_speech.py"
}

function ifttt_email(){
    code='~/AIY-projects-python/src/examples/voice/ifttt_email.py'
    step "$codeを実行します"
    echo "日経Linuxかラズパイマガジンの解説を参考にして$code内にキーを指定してください"
    wait
    run "python $code"
}

function conversation(){
    code='~/AIY-projects-python/src/examples/voice/conversation.py'
    step "$codeを実行します"
    echo "日経Linuxかラズパイマガジンの解説を参考にして$code内にキーを指定してください"
    wait
    run "python $code"
}


function delete_all_models(){
    step "すべてのモデルを消去します"
    run "cd ~"
    models=`googlesamples-assistant-devicetool list --model|&grep "Device Model Id"|cut -d : -f 2|tr -d " "`
    for model in ${models}; do
	run "googlesamples-assistant-devicetool delete --model $model"
    done
}

function delete_all_devices(){
    step "すべてのデバイスを消去します"
    run "cd ~"
    devices=`googlesamples-assistant-devicetool list --device|&grep "Device Instance Id"|cut -d : -f 2|tr -d " "`
    for device in ${devices}; do
	run "googlesamples-assistant-devicetool delete --device $device"
    done
}

function wait(){
    echo -e "${COLOR_INPUT}-------完了したらEnterを押してください-------${COLOR_END}"
    read input
    
}

function input_msg(){
    echo ""
    echo -e "${COLOR_INPUT}------------"$1"-------------${COLOR_END}"
    echo ""
}

function step(){
    echo ""
    echo -e "${COLOR_STEP}************************************ ステップ $step_counter ******************************************${COLOR_END}"
    echo ""
    echo -e "${COLOR_STEP}"$1"${COLOR_END}"
    echo ""
    echo -e "${COLOR_STEP}******************************************************************************************${COLOR_END}"
    echo ""

    step_counter=$((++step_counter))
}

function run(){
    echo ""
    echo -e "${COLOR_CMD}*********************** 以下のコマンドを実行します (コマンド $command_counter) ****************************${COLOR_END}"
    echo ""
    echo -e ${COLOR_CMD}$1${COLOR_END}
    echo ""
    echo -e "${COLOR_CMD}******************************************************************************************${COLOR_END}"
    echo ""
    eval $1

    command_counter=$((++command_counter))
}


if [ "`python --version |& cut -d . -f 1`" = "Python 2" ]; then
    echo "Start dev terminalで実行してください"
    exit 1
fi

step_counter=1
command_counter=1

echo -e "\n\n\
****************************************************************\n\
*                                                              *\n\
*                                                              *\n\
*                VoiceKitセットアップスクリプト                *\n\
*                            ver 1.0                           *\n\
*                                                              *\n\
*                                                              *\n\
****************************************************************\n\n\
"

while true
do
	echo ""
	commands=(\
	    "[setup]:\t\tVoiceKitの日本語初期セットアップを行います" \
	    "[demo_library]:\t\tOK,Googleを発話してGoogleAssistantと会話を行なうデモを実行します" \
	    "[demo_push]:\t\tボタンを押してGoogleAssistantと会話を行なうデモを実行します" \
	    "[cloud_speech]\t\tCloudSpeechのデモ(日本語)を実行します"\
	    "[ifttt_email]\t\tIFTTTを用いたメール送信のデモを実行します"\
	    "[conversation]\t\tDocomo雑談対話APIを用いた雑談会話のデモを実行します"\
	    "[delete_devices]:\t登録されているデバイスをすべて削除します" \
	    "[delete_models]:\t登録されているモデルをすべて削除します" \
	    "[exit]:\t\t\tこのスクリプトを終了します"\
	)
	echo -e "---command---\t\t\t-----------説明------------"
	for c in ${commands[@]}; do
		echo -e $c
	done
	input_msg "コマンドを入力してください"
	read command
	echo "you input "$command
	case "$command" in
	    "setup" ) setup ;;
	    "demo_library" ) assistant_library_demo ;;
	    "demo_push" ) assistant_push_demo ;;
	    "cloud_speech" ) cloud_speech ;;
	    "ifttt_email" ) ifttt_email ;;
	    "conversation" ) conversation ;;
	    "delete_models" ) delete_all_models ;;
	    "delete_devices" ) delete_all_devices ;;
	    "exit" ) break ;;
	    * ) echo "認識していないコマンドです" ;;
	esac

done
echo "終了します"



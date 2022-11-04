#!/bin/sh
# アカウントを生成しflow.jsonを整えるためのスクリプト
# flow initしemulatorを起動した後に実行する想定

gsed -i 's/f8d6e0586b0a20c7/0x01/g' flow.json

# anpan
array=($(flow keys generate |grep -e "Private Key" -e "Public Key"))
flow accounts create --key ${array[5]}
ANPAN_PRIV=${array[2]}
echo "anpan:"
echo "  Priv: ${array[2]}"
echo "  Pub: ${array[5]}"

# jam
array=($(flow keys generate |grep -e "Private Key" -e "Public Key"))
flow accounts create --key ${array[5]}
JAM_PRIV=${array[2]}
echo "jam:"
echo "  Priv: ${array[2]}"
echo "  Pub: ${array[5]}"

# baikin
array=($(flow keys generate |grep -e "Private Key" -e "Public Key"))
flow accounts create --key ${array[5]}
BAIKIN_PRIV=${array[2]}
echo "baikin:"
echo "  Priv: ${array[2]}"
echo "  Pub: ${array[5]}"

# flow.jsonの最後の3行を削除
sed -i -e '11,$d' flow.json 

# flow.jsonに追記
gsed -i \
      -e '$a \    },' \
      -e '$a \    "anpan": {' \
      -e '$a \      "address": "0x05",' \
      -e '$a \      "key": "'${ANPAN_PRIV}'"' \
      -e '$a \    },' \
      -e '$a \    "jam": {' \
      -e '$a \      "address": "0x06",' \
      -e '$a \      "key": "'${JAM_PRIV}'"' \
      -e '$a \    },' \
      -e '$a \    "baikin": {' \
      -e '$a \      "address": "0x07",' \
      -e '$a \      "key": "'${BAIKIN_PRIV}'"' \
      -e '$a \    }' \
      -e '$a \  },' \
      -e '$a \  "deployments": {' \
      -e '$a \    "emulator": {' \
      -e '$a \        "emulator-account": ["StrictNFT"]' \
      -e '$a \    }' \
      -e '$a \  },' \
      -e '$a \  "contracts": {' \
      -e '$a \    "StrictNFT": "./src/contracts/StrictNFT.cdc"' \
      -e '$a \  }' \
      -e '$a \}  ' \
flow.json








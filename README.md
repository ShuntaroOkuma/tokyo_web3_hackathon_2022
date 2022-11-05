# tokyo_web3_hackathon_2022

# 最速セットアップ

```sh
rm -rf flowdb/ flow.json
flow init
flow emulator --persist --contracts --simple-addresses -v
```

別ターミナルで下記を実行

```sh
bash setup_env.sh
flow deploy
flow transactions send --signer emulator-account src/transactions/mint_nft.cdc 0x01
flow transactions send src/transactions/get_info.cdc
flow transactions send --signer emulator-account src/transactions/get_nft_info.cdc 0
```

# 記載必須項目

TODO: 最後にちゃんと書く

- 使用した tech stacks

  - cadence

- 使用した Blockchain

  - flow

- deploy した Contract

  - `src/contracts/StrictNFT.cdc`

- application code やその他の file

  - トランザクションコード: `src/transactions/`
  - スクリプトコード: `src/scripts/`

- テスト手順を含むリポジトリへのリンク

  - ???

- 審査やテストのためにプロジェクトにアクセスする方法など
  - コントラクトの利用手順？

# 目的

- セキュアで柔軟な SBT Like な NFT を Flow/Cadence で作る
  - StrictNFT（仮）

# コンセプト

- SBT は

  - 譲渡できない
  - 鍵盗難対策
    - 移動できないから安全
    - ソーシャルリカバリーで鍵を再設定できる
  - 鍵紛失対策
    - ソーシャルリカバリーで鍵を再設定できる
      - 4 of 7 が推奨されている？
  - 参考：[Why we need wide adoption of social recovery wallets](https://vitalik.ca/general/2021/01/11/recovery.html)

- StrictNFT は

  - 譲渡できる
    - ただし、すぐには譲渡できない
      - NFT を ready 状態にして、所定の時間待つ（Ready Event が発火される）
      - その後、withdraw が可能になる
  - 鍵盗難対策
    - 譲渡するためには ready 状態にする必要があるが、その際に Ready Event が発火されるため、ユーザーが気づける可能性が高い（DApps やウォレットの仕様次第）
    - 実行した覚えのない Ready Event が発生したら、すぐに unready に戻し、鍵の再設定を実施することで、被害を抑えられる
      - 盗難時に ready 状態にしていた NFT は流出を防げない
  - 鍵紛失対策
    - ソーシャルリカバリーで鍵を再設定できる
      - 自分の別端末を含めた 2 of 3 くらいの最小構成でも十分堅牢ではない？
        - 7 人集めることにハードルの高さを感じる
      - そこにも、再設定のための ready が必要、という仕組みを入れる？

# StrictNFT の特徴

## 基本的には SBT の利用想定と同じ

- 免許証、パスポート
- 職務履歴証明、学歴証明
- 医療記録の証明
- NFT との紐付けによる正当性の証明（アーティストなど）
  - NFT として作品を発行するときに SBT をつける

## 譲渡可能、譲渡履歴が記録される

- 譲渡可能だが、上述の通り、ready 状態を遷移して withdraw する必要がある
- withdraw/deposit の回数、その際に通ったアドレスがコントラクトに記録される

- 譲渡できないデメリットとして、

  1. 権利を剥奪できない
  2. 発行機関（Minter）がユーザーの近くに必要になってしまう
     Minter リソースを持っているアカウントが mint し、直接エンドユーザーのアカウントに deposit する必要がある。
     つまりは、免許証の発行のために Minter リソースを持っているアカウントがボトルネックになってしまう。

- 譲渡が可能であれば

  1. 免許証や学歴証明などの権利を剥奪（destroy）することができる
     StrictNFT を所有しているユーザーの ready/withdraw のアクションが必要なので、当事者同士で協議の上、という前提
  2. 発行機関（Minter）と権利の承認機関を分けられる
     - あらかじめ発行機関が StrictNFT を複数 Mint しておき、免許証を発行する機関に配布しておく
     - 免許を取得したエンドユーザーに免許証発行機関が deposit する
     - そうすることで、複数の機関のウォレットを通過し、そのアドレスがコントラクトに記録されるため、信頼性の担保に繋がる
       - 所定の順番で機関を通ってきたことがわかる
       - 会社の承認フローに近いイメージ？

## 鍵盗難時のなりすましに対応できる

- 上述した通り、鍵が盗難され、アカウント所有者の意図せぬ withdraw があったとしても ready にされた段階で気づける
- また、愉快犯的な盗んで全て削除してといういたずらが、有名人への攻撃としてはあり得るが、destroy も ready 状態にする必要があるため事前に気づける

## [要検討]鍵盗難時に ready/unready のいたちごっこになる可能性がある

- 鍵盗難時に ready を繰り返される可能性がある
  - 何かユーザーが面倒なことをやることになるけど回復できるようにしておけば、頻繁に ready/unready するような悪質な利用はできない
  - 仮想通貨を払うとか、回復させたトークンはしばらく取引できなくなる、とか
  - 24 時間くらいそのトークンは取引できなくなる、であればすぐに実装できそう

# ローカル環境構築手順

## flow のインストール

## FlowCLI の初期化

```sh
flow init
```

## エミュレーターの起動

```sh
flow emulator --persist --contracts --simple-addresses -v
```

`--persist` でエミュレータのデータを永続化させている。上記コマンドを実行した時のカレントディレクトリに `flowdb` というフォルダが生成され、そこにファイルが格納される。

`--contracts` でデフォルトのコントラクトがデプロイされた状態でエミュレータが起動される。デプロイされるコントラクトはログに出力される。

```
INFO[0000] 📜  Flow contract                              FlowServiceAccount=0x0000000000000001
INFO[0000] 📜  Flow contract                              FlowToken=0x0000000000000003
INFO[0000] 📜  Flow contract                              FungibleToken=0x0000000000000002
INFO[0000] 📜  Flow contract                              FlowFees=0x0000000000000004
INFO[0000] 📜  Flow contract                              FlowStorageFees=0x0000000000000001
INFO[0000] 💵  FUSD contract                              FUSD=0x0000000000000001
INFO[0000] ✨  NFT contract                               NonFungibleToken=0x0000000000000001
INFO[0000] ✨  Metadata views contract                    MetadataViews=0x0000000000000001
INFO[0000] ✨  Example NFT contract                       ExampleNFT=0x0000000000000001
INFO[0000] ✨   NFT Storefront contract v2                NFTStorefrontV2=0x0000000000000001
INFO[0000] ✨   NFT Storefront contract                   NFTStorefront=0x0000000000000001
```

`--simple-addresses` でシンプルなアドレス形態にできる。

`-v` でログを詳細に出力してくれる（log()の結果も出力してくれるようになる）。

※ 環境をリセットしたいときは、`flowdb`フォルダを削除する。

## アカウントと flow.json のセットアップ

以下を実行するシェルは `setup_env.sh`。

### flow.json の更新

シンプルなアドレス形態を使う形で起動したため、`flow init`で自動生成された`flow.json`を書き換える。

変更前

```json
  "accounts": {
    "emulator-account": {
      "address": "f8d6e0586b0a20c7",
      "key": "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    }
  }
```

変更後

```json
  "accounts": {
    "emulator-account": {
		 "address": "0x01",
      "key": "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    }
  }
```

### アカウントを作る

アカウントを３つ作る。

1. 鍵を作る

```sh
flow keys generate
```

`Private Key`と`Public Key`をメモっておく。

2. アカウントを作る

表示された `Public Key` を使ってアカウントを作る。

```sh
flow accounts create --key <上記コマンドで表示されたPublic Key>
```

成功するとアドレスが表示される。

```
Transaction ID: eafaf43703e68e149a49996ddd5a30c1bc0605fe067df7f1a34801e922f910ba

Address  0x0000000000000005
Balance  0.00100000
Keys     1

（省略）
```

3. flow.json にアカウントの情報を追加する

`address`部分には上記で表示された`Address`を記載する。`key`部分には`flow keys generate`を実行したときに表示された`Private Key`を記載する。

3 つのアカウントを作成すると flow.json は以下のようになる。

```json
{
  "networks": {
    "emulator": "127.0.0.1:3569",
    "mainnet": "access.mainnet.nodes.onflow.org:9000",
    "testnet": "access.devnet.nodes.onflow.org:9000"
  },
  "accounts": {
    "emulator-account": {
      "address": "0x01",
      "key": "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    },
    "anpan": {
      "address": "0x05",
      "key": "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    },
    "jam": {
      "address": "0x06",
      "key": "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    },
    "baikin": {
      "address": "0x07",
      "key": "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    }
  }
}
```

# ユースケース

なりすましを防げるか、がわかるケースを明確にしておきたい
DApps でどう使うか、にも繋がる

1. anpan から jam に NFT を移動
   これは ready と transfer で普通にできる

   deposit 時に setAddress しているため、minter のアドレスが必ず最初に記録される

2. baikin のユーザーが anpan になりすまして、

- NFT を baikin に送ろうとする
- NFT を destroy しようとする
- Collection を destroy しようとする
- 自分のアイデンティティだと証明して現実世界で何かしようとする
  - 認証機関がチェック用 NFT を送り、ユーザーがそれを ready する
  - ReadyTimeHourPeriod を待つ間に unready されたり、鍵の再設定が行われなければ、本人と認証する
    とか
    ただ、それには時間がかかる…顔写真とかでの検証とかメールによる 2 段階認証のが手っ取り早い

# テストケース

## 前提

- minter: minter 所有者
- user: StrictNFT リソース所有者
- any: StrictNFT リソース非所有者

- emulator-contract: StrictNFT.cdc をデプロイするアカウント
- anpan
- jam
- baikin

## コントラクト

- `StrictNFT.cdc`をデプロイする

  `flow deploy`

## コレクション

- コレクションを作る

  anpan, jam, baikin のアカウントに作る

  ```
  flow transactions send --signer anpan src/transactions/create_collection.cdc
  flow transactions send --signer jam src/transactions/create_collection.cdc
  flow transactions send --signer baikin src/transactions/create_collection.cdc
  ```

- コレクションを破壊する

  コレクションを破壊するには、所持している NFT を全て ready にした上で、readyTimeHourPeriod が経過している状態にしておく必要がある

  逆に１つでも ready になっていない NFT がある、もしくは readyTimeHourPeriod が経過していない NFT があれば、破壊できない

  以下は anpan のコレクションを破壊する例

  ```
  flow transactions send --signer anpan src/transactions/destroy_collection.cdc
  ```

## トークン

### コントラクト所有者 関連

- emulator-account が minter を所有時に mint する

  `mint_nft.cdc`では `initReadyTimeHourPeriod`を 60 秒に設定している

  ```
  flow transactions send --signer emulator-account src/transactions/mint_nft.cdc 0x01
  ```

- emulator-account が minter を所有していないときに mint できない

  emulator-account から minter を移動した上で mint してみることで確認できる

  以下は anpan に minter を移動するときの例

  - emulator-account から minter を移動

    ```
    flow transactions build src/transactions/move_minter.cdc \
    --proposer emulator-account \
    --payer emulator-account \
    --authorizer emulator-account \
    --authorizer anpan \
    --filter payload --save move_minter_tx

    flow transactions sign move_minter_tx --signer anpan --filter payload --save move_minter_tx
    flow transactions sign move_minter_tx --signer emulator-account --filter payload --save move_minter_tx

    flow transactions send-signed move_minter_tx
    ```

  - emulator-account による mint の実行
    ```
    flow transactions send --signer emulator-account src/transactions/mint_nft.cdc 0x01
    ```

- コントラクト所有者であっても関数の実行や変数の更新ができない

  ```
  flow transactions send --signer emulator-account src/transactions/cannot_get_nft_info.cdc 0
  ```

### minter 所有者 関連

- minter 所有者が mint する

  上記の minter の anpan への移動を実施した上で以下を実施することで、emulator-account 以外でも mint できることを確認できる

  ```
  flow transactions send --signer anpan src/transactions/mint_nft.cdc 0x05`
  ```

- user は mint できない

  以下は jam が mint しようとする例。minter を持っていない前提

  ```
  flow transactions send --signer jam src/transactions/mint_nft.cdc 0x06
  ```

### コレクション所有者 関連

- initReadyTimeHourPeriod を 1 以上に設定できる

  以下は anpan が minter を持っている前提

  ```
  flow transactions send --signer anpan src/transactions/mint_nft.cdc 0x05
  ```

- initReadyTimeHourPeriod を 1 未満に設定できない

  以下は anpan が minter を持っている前提

  ```
  flow transactions send --signer anpan src/transactions/cannot_mint_nft.cdc 0x05
  ```

- user が別の user に deposit できる

  anpan が mint し、jam に deposit する例

  ```
  flow transactions send --signer anpan src/transactions/mint_nft.cdc 0x06
  ```

- user が自分のリソースを ready できる

  anpan が ID:1 の StrictNFT を所有している前提

  ```sh
  flow transactions send --signer anpan src/transactions/ready_nft.cdc 1
  flow transactions send --signer anpan src/transactions/get_nft_info.cdc 1
  ```

- user が指定した時間がたった NFT を withdraw できる

  上記の ready した瞬間から initReadyTimeHourPeriod に設定した時間が経過した前提

  以下は anpan から jam に transfer する例

  ```sh
  flow transactions send --signer anpan src/transactions/transfer_nft.cdc 0x06 1
  flow transactions send --signer jam src/transactions/get_nft_info.cdc 1
  ```

- user が withdraw した後の NFT が ready が false かつ readyTime が nil になっている

  ```
  flow transactions send --signer jam src/transactions/get_nft_info.cdc 1
  ```

- user が ready=false の NFT を withdraw できない

  ```
  flow transactions send --signer jam src/transactions/transfer_nft.cdc 0x01 1
  ```

- user が指定した時間がたっていない ready 状態の NFT を withdraw できない

  ```
  flow transactions send --signer jam src/transactions/ready_withdraw_nft.cdc 1
  ```

- user が指定した時間が経過した NFT を destroy できるか

  ```sh
  flow transactions send --signer jam src/transactions/ready_nft.cdc 1
  (60秒 待つ)
  flow transactions send --signer jam src/transactions/destroy_nft.cdc 1
  flow transactions send --signer jam src/transactions/get_nft_info.cdc 1
  ```

- user が指定した時間がたっていない NFT を destroy できない

  ```
  flow transactions send --signer emulator-account src/transactions/ready_destroy_nft.cdc 0
  ```

- user が ready 状態の NFT を unready できる

  上記で ID:0 の NFT を ready にした前提

  ```
  flow transactions send --signer emulator-account src/transactions/get_nft_info.cdc 0
  flow transactions send --signer emulator-account src/transactions/unready_nft.cdc 0
  flow transactions send --signer emulator-account src/transactions/get_nft_info.cdc 0
  ```

### 情報確認 関連

- withdraw と deposit の回数、アドレスと時刻が記録されている

  ```
  flow transactions send --signer emulator-account src/transactions/get_nft_info.cdc 0
  ```

- アドレスが 5 つ以下になっているか、FIFO になっている

  ```sh
  flow transactions send --signer emulator-account src/transactions/ready_nft.cdc 0
  flow transactions send --signer emulator-account src/transactions/transfer_nft.cdc 0x05 0
  flow transactions send --signer anpan src/transactions/ready_nft.cdc 0
  flow transactions send --signer anpan src/transactions/transfer_nft.cdc 0x06 0
  flow transactions send --signer jam src/transactions/ready_nft.cdc 0
  flow transactions send --signer jam src/transactions/transfer_nft.cdc 0x01 0
  flow transactions send --signer emulator-account src/transactions/ready_nft.cdc 0
  flow transactions send --signer emulator-account src/transactions/transfer_nft.cdc 0x05 0
  flow transactions send --signer anpan src/transactions/ready_nft.cdc 0
  flow transactions send --signer anpan src/transactions/transfer_nft.cdc 0x06 0

  flow transactions send --signer jam src/transactions/get_nft_info.cdc 0
  ```

- Ready の Event が発火される

  ```
  flow transactions send --signer jam src/transactions/ready_nft.cdc 0
  ```

- Unready の Event が発火される

  ```
  flow transactions send --signer jam src/transactions/unready_nft.cdc 0
  ```

- any が withdrawCount, depositCount, addressList, readyTimeHourPeriod を確認できる

  ```
  flow scripts execute src/scripts/get_nft_view.cdc 0x01 0
  ```

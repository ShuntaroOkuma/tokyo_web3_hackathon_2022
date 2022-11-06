/*
Minterリソースを別アカウントに移動するトランザクション

複数の署名者が必要なので、flow transactions send xxx は利用できない。

build, sign, send-signed の段階を踏む必要がある。
注意点として、最後にpayerに指定したアカウントのsignをする必要がある。

例えば、emulator-accountからanapnにMinterリソースを送信するコマンドは以下。

flow transactions build src/transactions/move_minter.cdc \
  --proposer emulator-account \
  --payer emulator-account \
  --authorizer emulator-account \
  --authorizer anpan \
  --filter payload --save move_minter_tx

flow transactions sign move_minter_tx --signer anpan --filter payload --save move_minter_tx
flow transactions sign move_minter_tx --signer emulator-account --filter payload --save move_minter_tx

flow transactions send-signed move_minter_tx

*/

import StrictNFT from 0x01
import NonFungibleToken from 0x01

transaction() {

  prepare(sender: AuthAccount, receiver: AuthAccount){
    pre {
      // senderがminterを持っているか
      sender.borrow<&StrictNFT.NFTMinter>(from: StrictNFT.MinterStoragePath) != nil: "Sender do not have minter."
    }
    // minterをsenderから取り出し
    let minter <- sender.load<@StrictNFT.NFTMinter>(from: StrictNFT.MinterStoragePath)!
    // minterをreceiverへ格納
    receiver.save(<-minter, to: StrictNFT.MinterStoragePath)
    log("Moved Minter resource.")
  }
}
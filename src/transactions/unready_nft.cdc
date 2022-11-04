/*
NFTをunready状態にするためのトランザクション

実行方法

- `flow transactions send --signer emulator-account src/transactions/unready_nft.cdc 0`
- `flow transactions send --signer anpan src/transactions/unready_nft.cdc 1`
*/

import StrictNFT from 0x01
import NonFungibleToken from 0x01

transaction(id: UInt64) {

  prepare(signer: AuthAccount) {
    log(signer.address)

    let CollectionRef = signer.borrow<&StrictNFT.Collection>(from: StrictNFT.CollectionStoragePath)
    if CollectionRef != nil {
      CollectionRef?.unready(id: id)
    } else {
      log("  do not have StrictNFT Collection")
    }
  }
}



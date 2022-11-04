/*
NFTをready状態にした後すぐの場合はdestroyできないことを確認するためのトランザクション

実行方法

- `flow transactions send --signer emulator-account src/transactions/ready_destroy_nft.cdc 0`
- `flow transactions send --signer anpan src/transactions/ready_destroy_nft.cdc 1`
*/

import StrictNFT from 0x01
import NonFungibleToken from 0x01

transaction(id: UInt64) {

  prepare(signer: AuthAccount) {
    log(signer.address)

    let CollectionRef = signer.borrow<&StrictNFT.Collection>(from: StrictNFT.CollectionStoragePath)
    if CollectionRef != nil {
      let nft <- CollectionRef?.withdraw(withdrawID: id) ?? panic("Could not withdraw nft")
      destroy nft
      log("destory nft, successfully.")
    } else {
      log("  do not have StrictNFT Collection")
    }
  }
}
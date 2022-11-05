/*
NFTをdestroyためのトランザクション

実行方法

- `flow transactions send --signer emulator-account src/transactions/destroy_nft.cdc 0`
- `flow transactions send --signer anpan src/transactions/destroy_nft.cdc 1`
*/

import StrictNFT from 0x01
import NonFungibleToken from 0x01

transaction(id: UInt64) {

  prepare(signer: AuthAccount) {
    log(signer.address)

    let CollectionRef = signer.borrow<&StrictNFT.Collection>(from: StrictNFT.CollectionStoragePath)
    if CollectionRef != nil {
      // withdraw
      let nft <- CollectionRef?.withdraw(withdrawID: id) ?? panic("Could not withdraw nft")
      // destroy
      destroy nft
      log("destroy nft, successfully.")
    } else {
      log("  do not have StrictNFT Collection")
    }
  }
}
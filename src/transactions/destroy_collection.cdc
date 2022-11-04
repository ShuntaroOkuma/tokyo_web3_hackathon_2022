/*
Collectionをdestoryするためのトランザクション

実行方法

- `flow transactions send --signer emulator-account src/transactions/destroy_collection.cdc`
*/

import StrictNFT from 0x01
import NonFungibleToken from 0x01

transaction() {

  prepare(signer: AuthAccount) {
    log(signer.address)

    // Collectionごとdestroyすることを試すためにload
    let Collection <- signer.load<@StrictNFT.Collection>(from: StrictNFT.CollectionStoragePath)
        ?? panic("signer does not have Collection")
    destroy Collection
  }
}
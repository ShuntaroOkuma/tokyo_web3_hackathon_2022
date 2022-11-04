/*
NFTをdestoryするためのトランザクション

実行方法

- `flow transactions send --signer emulator-account src/transactions/destroy_nft.cdc 0`
- `flow transactions send --signer anpan src/transactions/destroy_nft.cdc 1`
*/

import StrictNFT from 0x01
import NonFungibleToken from 0x01

transaction(id: UInt64) {

  prepare(signer: AuthAccount) {
    log(signer.address)

    // Collectionごとdestroyすることを試すためにload
    let Collection <- signer.load<@StrictNFT.Collection>(from: StrictNFT.CollectionStoragePath)
        ?? panic("signer does not have Collection")
    Collection.ready(id: id)
    destroy Collection
    panic("intentional panic") // destroyできてしまった時のことを考えて強制的にavertさせている
  }
}
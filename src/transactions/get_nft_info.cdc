/*
１つのNFTの情報を取得するためのトランザクション

実行方法
- `flow transactions send --signer <Account名> src/transactions/get_nft_info.cdc <NFTのID>`

例
- `flow transactions send --signer emulator-account src/transactions/get_nft_info.cdc 0`
- `flow transactions send --signer anpan src/transactions/get_nft_info.cdc 1`
*/

import StrictNFT from 0x01
import NonFungibleToken from 0x01
import MetadataViews from 0x01

transaction(id: UInt64) {

  prepare(signer: AuthAccount) {
    log(signer.address)

    // tokenリソースの確認
    let CollectionRef = signer.getCapability(StrictNFT.CollectionPublicPath)
                                  .borrow<&{StrictNFT.StrictNFTCollectionPublic}>()
                                    ?? panic("Could not borrow a reference to the collection")
    if CollectionRef != nil {
      let nftRef = CollectionRef.borrowStrictNFT(id: id)
      if nftRef != nil {
        log(nftRef)
      } else {
        log("  do not have NFT of this ID")
      }
    } else {
      log("  do not have StrictNFT Collection")
    }
  }
}




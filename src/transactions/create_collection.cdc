/*
空っぽのCollectionを署名アカウントのストレージに格納するためのトランザクション

実行方法

- `flow transactions send --signer anpan src/transactions/create_collection.cdc`

*/

import StrictNFT from 0x01
import NonFungibleToken from 0x01
import MetadataViews from 0x01

transaction {
  prepare(signer: AuthAccount) {
    if (signer.getCapability<&AnyResource{StrictNFT.StrictNFTCollectionPublic}>(StrictNFT.CollectionPublicPath).borrow() == nil){
      // 初期設定（Collectionの作成とlinkの作成）
      signer.save(<- StrictNFT.createEmptyCollection(), to: StrictNFT.CollectionStoragePath)
      signer.link<&StrictNFT.Collection{NonFungibleToken.CollectionPublic, StrictNFT.StrictNFTCollectionPublic, MetadataViews.ResolverCollection}>
              (StrictNFT.CollectionPublicPath, target: StrictNFT.CollectionStoragePath)
      log("Create Collection, successfully.")
    } else {
      log("Collection already exists.")
    }
  }
}
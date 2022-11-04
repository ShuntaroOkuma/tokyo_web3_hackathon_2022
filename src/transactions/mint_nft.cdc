/*
Minterリソースを使って、NFTをmintし、Collectionに格納するためのトランザクション

実行方法

- `flow transactions send --signer <Minter所有者> src/transactions/mint_nft.cdc <NFTを受け取るアカウントのアドレス>`

*/

import StrictNFT from 0x01
import NonFungibleToken from 0x01

transaction(recipient: Address) {
  let minterRef: &StrictNFT.NFTMinter

  prepare(signer: AuthAccount){
    pre {
      // minterを持っているか
      signer.borrow<&StrictNFT.NFTMinter>(from: /storage/StrictNFTMinter) != nil: "Account do not have minter."
      // receiverのインターフェースを取得できるか
      getAccount(recipient).getCapability<&AnyResource{StrictNFT.StrictNFTCollectionPublic}>(StrictNFT.CollectionPublicPath)
                .borrow() != nil: "Receiver do not have Collection"
    }
    self.minterRef = signer.borrow<&StrictNFT.NFTMinter>(from: /storage/StrictNFTMinter)!
  }

  execute {
    let recipientRef = getAccount(recipient).getCapability<&AnyResource{NonFungibleToken.CollectionPublic}>(StrictNFT.CollectionPublicPath).borrow()!
    log("Recipient NFT IDs before execute:")
    log(recipientRef.getIDs())
    
    self.minterRef.mintNFT(
      recipient: recipientRef,
      name: "testNFT",
      description: "テストNFT",
      thumbnail: "https://dummyimage.com/600x400/000/fff",
      royalties: [],
      initReadyTimeHourPeriod: 60,
    )

    log("Recipient NFT IDs after execute:")
    log(recipientRef.getIDs())
    log("create nft, successfully.")
  }

}
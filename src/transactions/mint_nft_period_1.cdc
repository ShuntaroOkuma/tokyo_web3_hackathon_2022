/*
Minterリソースを使って、NFTをmintし、Collectionに格納するためのトランザクション

ただしテストのために、initReadyTimeHourPeriod: 1 を指定している

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
      name: "StrictNFT ver0.1",
      description: "This is StrictNFT developed for tokyo web3 hackathon.",
      thumbnail: "https://raw.githubusercontent.com/ShuntaroOkuma/tokyo_web3_hackathon_2022/main/metadata/nft_image.png",
      royalties: [],
      initReadyTimeHourPeriod: 1,
    )

    log("Recipient NFT IDs after execute:")
    log(recipientRef.getIDs())
    log("create nft, successfully.")
  }

}
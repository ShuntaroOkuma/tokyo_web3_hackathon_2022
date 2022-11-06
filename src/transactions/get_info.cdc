/*
エミュレーター上の情報を取得するためのトランザクション

実行方法

- `flow transactions send --signer emulator-account src/transactions/get_info.cdc`
- `flow transactions send --signer anpan src/transactions/get_info.cdc`
*/

import StrictNFT from 0x01

transaction {

  prepare(signer: AuthAccount) {
    log(signer.address)

    // contractの確認
    log("  have below contracts:")
    log(signer.contracts.names)

    // tokenリソースの確認
    let CollectionRef = signer.borrow<&StrictNFT.Collection>(from: StrictNFT.CollectionStoragePath)
    if CollectionRef != nil {
      // ownedNFTsの数
      log("  have ownedNFTs which length is:")
      log(CollectionRef?.ownedNFTs?.length)
      
      // ownedNFTのID
      log("  have below NFT IDs:")
      log(CollectionRef?.getIDs())
    } else {
      log("  do not have StrictNFT Collection")
    }

    // minterリソースの確認
    let minterRef = signer.borrow<&StrictNFT.NFTMinter>(from: StrictNFT.MinterStoragePath)
    if minterRef != nil {
      log("  have Minter resource")
    } else {
      log("  do not have Minter resource")
    }
  }
}




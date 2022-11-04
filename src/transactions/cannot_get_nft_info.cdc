/*
１つのNFTの情報を取得できないことを確認するためのトランザクション

実行方法
- `flow transactions send --signer <Account名> src/transactions/get_nft_info.cdc <NFTのID>`

例
- `flow transactions send --signer admin src/transactions/get_nft_info.cdc 0`
- `flow transactions send --signer anpan src/transactions/get_nft_info.cdc 1`
*/

import StrictNFT from 0x01
import NonFungibleToken from 0x01

transaction(id: UInt64) {

  prepare(signer: AuthAccount) {
    log(signer.address)

    // tokenリソースの確認
    let CollectionRef = signer.borrow<&StrictNFT.Collection>(from: StrictNFT.CollectionStoragePath)
    if CollectionRef != nil {
      let nftRef = CollectionRef?.borrowStrictNFT(id: id)

      // 関数系
      nftRef.incrementWithdraw() // unknown memberとなるはず
      nftRef.incrementDeposit() // unknown memberとなるはず
      nftRef.setAddress(signer.address) // unknown memberとなるはず
      nftRef.ready() // unknown memberとなるはず
      nftRef.unready() // unknown memberとなるはず
      nftRef.addReadyTime() // unknown memberとなるはず
      nftRef.delReadyTime() // unknown memberとなるはず

      // 変数系
      nftRef.withdrawCount = 0 // unknown memberとなるはず
      nftRef.depositCount = 0 // unknown memberとなるはず
      nftRef.addressList = [] // unknown memberとなるはず
      nftRef.isReady = true // unknown memberとなるはず
      nftRef.readyTime = 2? // unknown memberとなるはず
      nftRef.readyTimeHourPeriod = 2 // unknown memberとなるはず
    } else {
      log("  do not have StrictNFT Collection")
    }
  }
}




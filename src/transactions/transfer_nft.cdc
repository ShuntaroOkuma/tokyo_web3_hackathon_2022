/*
NFTをwithdrawし、他のアカウントにdepositするためのトランザクション

実行方法

- `flow transactions send --signer <NFT所有者> src/transactions/transfer_nft.cdc <NFTを受け取るアカウントのアドレス> <NFTのID>`

*/

import StrictNFT from 0x01
import NonFungibleToken from 0x01

transaction(recipient: Address, withdrawID: UInt64) {
  let withdrawRef: &StrictNFT.Collection

  let depositRef: &{NonFungibleToken.CollectionPublic}

  prepare(signer: AuthAccount){
    // borrow a reference to the signer's NFT collection
    self.withdrawRef = signer
        .borrow<&StrictNFT.Collection>(from: StrictNFT.CollectionStoragePath)
        ?? panic("Account does not store an object at the specified path")
    
    // get the recipients public account object
    let recipient = getAccount(recipient)

    // borrow a public reference to the receivers collection
    self.depositRef = recipient
        .getCapability(StrictNFT.CollectionPublicPath)
        .borrow<&{NonFungibleToken.CollectionPublic}>()
        ?? panic("Could not borrow a reference to the receiver's collection")
  }

  execute {
    // withdraw the NFT from the owner's collection
    let nft <- self.withdrawRef.withdraw(withdrawID: withdrawID)

    // Deposit the NFT in the recipient's collection
    self.depositRef.deposit(token: <-nft)

    log("transfer nft, successfully.")    
  }

  post {
    !self.withdrawRef.getIDs().contains(withdrawID): "Original owner should not have the NFT anymore"
    self.depositRef.getIDs().contains(withdrawID): "The reciever should now own the NFT"
  }

}
/*
NFTの情報を取得するためのスクリプト(getCount編)

実行方法

- `flow scripts execute src/scripts/get_nft_info.cdc <NFTを持っているアカウントアドレス> <NFTのID>`

*/

import StrictNFT from 0x01
import NonFungibleToken from 0x01

pub fun main(address: Address, id: UInt64):{String: UInt64} {
  let account = getAccount(address)

  let collectionRef = account
    .getCapability(StrictNFT.CollectionPublicPath)
        .borrow<&{StrictNFT.StrictNFTCollectionPublic}>()
        ?? panic("Could not borrow capability from public collection at specified path")
  
  return collectionRef.getCount(id: id)
}
// StrictNFTをデプロイしたときに生成されるオブジェクトを削除するためのトランザクション

import StrictNFT from 0x01

transaction {
  prepare(acct: AuthAccount){
    destroy acct.load<@StrictNFT.Collection>(from: /storage/StrictNFTCollection)

    acct.unlink(/public/StrictNFTCollection)

    destroy acct.load<@StrictNFT.NFTMinter>(from: /storage/StrictNFTMinter)
  }
}
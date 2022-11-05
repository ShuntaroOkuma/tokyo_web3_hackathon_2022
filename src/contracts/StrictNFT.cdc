import NonFungibleToken from 0x01
import MetadataViews from 0x01

pub contract StrictNFT: NonFungibleToken {

    pub var totalSupply: UInt64

    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)
    pub event Ready(id: UInt64)
    pub event Unready(id: UInt64)

    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath
    pub let MinterStoragePath: StoragePath

    pub resource NFT: NonFungibleToken.INFT, MetadataViews.Resolver {
        pub let id: UInt64
        
        access(contract) var withdrawCount: UInt64 // withdrawされた回数
        access(contract) var depositCount: UInt64 // depositされた回数
        access(contract) var addressList: [[AnyStruct]] // depositした時刻とその瞬間のownerアドレスを格納するDictionary

        access(contract) var isReady: Bool // ready状態かどうかのステータス
        access(contract) var readyTime: UInt64? // ready状態にした瞬間の時間を格納する変数
        access(contract) var readyTimeHourPeriod: UInt64 // ready状態になるまでの時間

        pub let name: String
        pub let description: String
        pub let thumbnail: String
        access(self) let royalties: [MetadataViews.Royalty]
        access(self) let metadata: {String: AnyStruct}

        // +1 以外させないために関数化
        access(contract) fun incrementWithdraw(){
            self.withdrawCount = self.withdrawCount + 1
        }
        access(contract) fun incrementDeposit(){
            self.depositCount = self.depositCount + 1
        }

        // アドレスのセットしかさせないために関数化
        access(contract) fun setAddress(addressInfo: [AnyStruct]){
            // アドレスは５つまで、それ以上はFILO
            while self.addressList.length >= 5 {
                self.addressList.removeFirst()
            }
            self.addressList.append(addressInfo)
        }

        // ready状態にするための関数
        access(contract) fun ready(){
            self.isReady = true
        }
        // ready状態を解除するための関数
        access(contract) fun unready(){
            self.isReady = false
        }
        // ready状態にした瞬間の時間をセットするための関数
        access(contract) fun addReadyTime(readyTime: UInt64){
            self.readyTime = readyTime
        }
        // ready状態にした瞬間の時間を削除するための関数
        access(contract) fun delReadyTime(){
            self.readyTime = nil
        }

        init(
            id: UInt64,
            name: String,
            description: String,
            thumbnail: String,
            royalties: [MetadataViews.Royalty],
            metadata: {String: AnyStruct},
            initReadyTimeHourPeriod: UInt64
        ) {
            self.id = id
            self.name = name
            self.description = description
            self.thumbnail = thumbnail
            self.royalties = royalties
            self.metadata = metadata
            self.withdrawCount = 0
            self.depositCount = 0
            self.addressList = []
            self.isReady = false 
            self.readyTime = nil
            self.readyTimeHourPeriod = initReadyTimeHourPeriod
        }
    
        pub fun getViews(): [Type] {
            return [
                Type<MetadataViews.Display>(),
                Type<MetadataViews.Royalties>(),
                Type<MetadataViews.Editions>(),
                Type<MetadataViews.ExternalURL>(),
                Type<MetadataViews.NFTCollectionData>(),
                Type<MetadataViews.NFTCollectionDisplay>(),
                Type<MetadataViews.Serial>(),
                Type<MetadataViews.Traits>()
            ]
        }

        pub fun resolveView(_ view: Type): AnyStruct? {
            switch view {
                case Type<MetadataViews.Display>():
                    return MetadataViews.Display(
                        name: self.name,
                        description: self.description,
                        thumbnail: MetadataViews.HTTPFile(
                            url: self.thumbnail
                        )
                    )
                case Type<MetadataViews.Editions>():
                    // There is no max number of NFTs that can be minted from this contract
                    // so the max edition field value is set to nil
                    let editionInfo = MetadataViews.Edition(name: "Strict NFT Edition", number: self.id, max: nil)
                    let editionList: [MetadataViews.Edition] = [editionInfo]
                    return MetadataViews.Editions(
                        editionList
                    )
                case Type<MetadataViews.Serial>():
                    return MetadataViews.Serial(
                        self.id
                    )
                case Type<MetadataViews.Royalties>():
                    return MetadataViews.Royalties(
                        self.royalties
                    )
                case Type<MetadataViews.ExternalURL>():
                    return MetadataViews.ExternalURL("https://example-nft.onflow.org/".concat(self.id.toString()))

                case Type<MetadataViews.NFTCollectionData>():
                    return MetadataViews.NFTCollectionData(
                        storagePath: StrictNFT.CollectionStoragePath,
                        publicPath: StrictNFT.CollectionPublicPath,
                        providerPath: /private/StrictNFTCollection,
                        publicCollection: Type<&StrictNFT.Collection{StrictNFT.StrictNFTCollectionPublic}>(),
                        publicLinkedType: Type<&StrictNFT.Collection{StrictNFT.StrictNFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(),
                        providerLinkedType: Type<&StrictNFT.Collection{StrictNFT.StrictNFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Provider,MetadataViews.ResolverCollection}>(),
                        createEmptyCollectionFunction: (fun (): @NonFungibleToken.Collection {
                            return <-StrictNFT.createEmptyCollection()
                        })
                    )
                case Type<MetadataViews.NFTCollectionDisplay>():
                    let media = MetadataViews.Media(
                        file: MetadataViews.HTTPFile(
                            url: "https://raw.githubusercontent.com/ShuntaroOkuma/tokyo_web3_hackathon_2022/main/metadata/collection_image.png"
                        ),
                        mediaType: "image/png"
                    )
                    return MetadataViews.NFTCollectionDisplay(
                        name: "The StrictNFT Collection",
                        description: "This collection is used for StrictNFT.", // コレクションの説明
                        externalURL: MetadataViews.ExternalURL("https://github.com/ShuntaroOkuma/tokyo_web3_hackathon_2022"),
                        squareImage: media,
                        bannerImage: media,
                        socials: {
                            "twitter": MetadataViews.ExternalURL("https://twitter.com/shun25533233")
                        }
                    )
                case Type<MetadataViews.Traits>():
                    // exclude mintedTime and foo to show other uses of Traits
                    let excludedTraits = ["mintedTime", "foo"]
                    let traitsView = MetadataViews.dictToTraits(dict: self.metadata, excludedNames: excludedTraits)

                    // mintedTime is a unix timestamp, we should mark it with a displayType so platforms know how to show it.
                    let mintedTimeTrait = MetadataViews.Trait(name: "mintedTime", value: self.metadata["mintedTime"]!, displayType: "Date", rarity: nil)
                    traitsView.addTrait(mintedTimeTrait)

                    // foo is a trait with its own rarity
                    let fooTraitRarity = MetadataViews.Rarity(score: 10.0, max: 100.0, description: "Common")
                    let fooTrait = MetadataViews.Trait(name: "foo", value: self.metadata["foo"], displayType: nil, rarity: fooTraitRarity)
                    traitsView.addTrait(fooTrait)
                    
                    return traitsView

            }
            return nil
        }
    }

    pub resource interface StrictNFTCollectionPublic {
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun getIDs(): [UInt64]
        pub fun getWithdrawCount(id: UInt64): UInt64?
        pub fun getDepositCount(id: UInt64): UInt64?
        pub fun getAddressList(id: UInt64): [[AnyStruct]]?
        pub fun getReadyTimeHourPeriod(id: UInt64): UInt64?
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
        pub fun borrowStrictNFT(id: UInt64): &StrictNFT.NFT? {
            post {
                (result == nil) || (result?.id == id):
                    "Cannot borrow StrictNFT reference: the ID of the returned reference is incorrect"
            }
        }
    }

    pub resource Collection: StrictNFTCollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection {
        // dictionary of NFT conforming tokens
        // NFT is a resource type with an `UInt64` ID field
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        init () {
            self.ownedNFTs <- {}
        }

        pub fun ready(id: UInt64) {
            if self.ownedNFTs[id] != nil {
                let ref = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)! as! &StrictNFT.NFT
                ref.ready()
                let readyTime = UInt64(getCurrentBlock().timestamp)
                ref.addReadyTime(readyTime: readyTime)
                emit Ready(id: ref.id)
            } else {
                log("Do not have NFT of the ID.")
            }
        }

        pub fun unready(id: UInt64) {
            if self.ownedNFTs[id] != nil {
                let ref = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)! as! &StrictNFT.NFT
                ref.unready()
                ref.delReadyTime()
                emit Unready(id: ref.id)
            } else {
                log("Do not have NFT of the ID.")
            }
        }

        // withdraw removes an NFT from the collection and moves it to the caller
        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) as! @StrictNFT.NFT? ?? panic("missing NFT")

            // ready状態かどうかのassert
            assert(token.isReady == true, message:"token status is not ready")
            // readyにしてからreadyTimeHourPeriod時間が経過しているかどうかのassert
            if token.readyTime != nil {
                    // 安全な使えるようにするために最低でも1時間は間隔を空けたいという想いから、"Hour"という設定を強制している
                    // TODO: 後で変更する
                    // 本来は以下のように 3600秒をかけた秒数をassertで比較する
                    // が、今はテストしやすくするために3600はかけていない
                    //assert( token.readyTime! + token.readyTimeHourPeriod * UInt64(3600) < getCurrentBlock().timestamp as! UInt64, 
                    //                                        message:"the specified time has not yet passed")
                    assert( token.readyTime! + token.readyTimeHourPeriod < UInt64(getCurrentBlock().timestamp), 
                                                            message:"the specified time has not yet passed")
            } else {
                panic("token status is not ready")
            }

            token.incrementWithdraw()

            emit Withdraw(id: token.id, from: self.owner?.address)

            token.unready()
            token.delReadyTime()

            return <-token
        }

        // deposit takes a NFT and adds it to the collections dictionary
        // and adds the ID to the id array
        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @StrictNFT.NFT
            token.incrementDeposit()

            token.setAddress(addressInfo: [UInt64(getCurrentBlock().timestamp), self.owner!.address]) // ownerのアドレスを刻む

            let id: UInt64 = token.id

            // add the new token to the dictionary which removes the old one
            let oldToken <- self.ownedNFTs[id] <- token

            emit Deposit(id: id, to: self.owner?.address)

            destroy oldToken
        }

        // getIDs returns an array of the IDs that are in the collection
        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        pub fun getWithdrawCount(id: UInt64): UInt64? {
            if self.ownedNFTs[id] != nil {
                let ref =  (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)! as! &StrictNFT.NFT
                return ref.withdrawCount
            } else {
                return nil
            }
        }

        pub fun getDepositCount(id: UInt64): UInt64? {
            if self.ownedNFTs[id] != nil {
                let ref =  (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)! as! &StrictNFT.NFT
                return ref.depositCount
            } else {
                return nil
            }
        }

        pub fun getAddressList(id: UInt64): [[AnyStruct]]? {
            if self.ownedNFTs[id] != nil {
                let ref =  (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)! as! &StrictNFT.NFT
                return ref.addressList
            } else {
                return nil
            }
        }

        pub fun getReadyTimeHourPeriod(id: UInt64): UInt64? {
            if self.ownedNFTs[id] != nil {
                let ref =  (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)! as! &StrictNFT.NFT
                return ref.readyTimeHourPeriod
            } else {
                return nil
            }
        }

        // borrowNFT gets a reference to an NFT in the collection
        // so that the caller can read its metadata and call its methods
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return (&self.ownedNFTs[id] as &NonFungibleToken.NFT?)!
        }

        pub fun borrowStrictNFT(id: UInt64): &StrictNFT.NFT? {
            if self.ownedNFTs[id] != nil {
                // Create an authorized reference to allow downcasting
                return (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)! as! &StrictNFT.NFT
            }
            return nil
        }

        pub fun borrowViewResolver(id: UInt64): &AnyResource{MetadataViews.Resolver} {
            let nft = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
            let StrictNFT = nft as! &StrictNFT.NFT
            return StrictNFT as &AnyResource{MetadataViews.Resolver}
        }

        destroy() {
            for id in self.ownedNFTs.keys {
                let tokenRef = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)! as! &StrictNFT.NFT
                // ready状態かどうかのassert
                assert(tokenRef.isReady == true, message:"token status is not ready")
                // readyにしてからreadyTimeHourPeriod時間が経過しているかどうかのassert
                if tokenRef.readyTime != nil {
                    // 本来は以下のように 3600秒をかけた秒数をassertで比較する
                    // テストしやすくするために3600はかけていない
                    //assert( tokenRef.readyTime! + tokenRef.readyTimeHourPeriod * UInt64(3600) < getCurrentBlock().timestamp as! UInt64, 
                    //                                        message:"the specified time has not yet passed")
                    assert( tokenRef.readyTime! + tokenRef.readyTimeHourPeriod < UInt64(getCurrentBlock().timestamp), 
                                                            message:"the specified time has not yet passed")


                } else {
                    panic("token status is not ready")
                }
            }
            destroy self.ownedNFTs
        }
    }

    // public function that anyone can call to create a new empty collection
    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        return <- create Collection()
    }

    pub resource NFTMinter {

        // mintNFT mints a new NFT with a new ID
        // and deposit it in the recipients collection using their collection reference
        pub fun mintNFT(
            recipient: &{NonFungibleToken.CollectionPublic},
            name: String,
            description: String,
            thumbnail: String,
            royalties: [MetadataViews.Royalty],
            initReadyTimeHourPeriod: UInt64
        ) {
            pre {
                initReadyTimeHourPeriod >= 1:
                    "initReadyTimeHourPeriod must be greater than or equal to 1"
            }
            let metadata: {String: AnyStruct} = {}
            let currentBlock = getCurrentBlock()
            metadata["mintedBlock"] = currentBlock.height
            metadata["mintedTime"] = currentBlock.timestamp
            metadata["minter"] = recipient.owner!.address

            // this piece of metadata will be used to show embedding rarity into a trait
            metadata["foo"] = "bar"

            // create a new NFT
            var newNFT <- create NFT(
                id: StrictNFT.totalSupply,
                name: name,
                description: description,
                thumbnail: thumbnail,
                royalties: royalties,
                metadata: metadata,
                initReadyTimeHourPeriod: initReadyTimeHourPeriod
            )

            // deposit it in the recipient's account using their reference
            recipient.deposit(token: <-newNFT)

            StrictNFT.totalSupply = StrictNFT.totalSupply + UInt64(1)
        }
    }

    init() {
        // Initialize the total supply
        self.totalSupply = 0

        // Set the named paths
        self.CollectionStoragePath = /storage/StrictNFTCollection
        self.CollectionPublicPath = /public/StrictNFTCollection
        self.MinterStoragePath = /storage/StrictNFTMinter

        // Create a Collection resource and save it to storage
        let collection <- create Collection()
        self.account.save(<-collection, to: self.CollectionStoragePath)

        // create a public capability for the collection
        self.account.link<&StrictNFT.Collection{NonFungibleToken.CollectionPublic, StrictNFT.StrictNFTCollectionPublic, MetadataViews.ResolverCollection}>(
            self.CollectionPublicPath,
            target: self.CollectionStoragePath
        )

        // Create a Minter resource and save it to storage
        let minter <- create NFTMinter()
        self.account.save(<-minter, to: self.MinterStoragePath)

        emit ContractInitialized()
    }
}

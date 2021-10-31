
import Foundation
import SwiftyJSON

fileprivate let epgChannelIdKey = "epgChannelId"
fileprivate let epgIdKey = "epgId"
fileprivate let relatedMediaIdKey = "relatedMediaId"
fileprivate let cridKey = "crid"
fileprivate let linearAssetIdKey = "linearAssetId"
fileprivate let enableCdvrKey = "enableCdvr"
fileprivate let enableCatchUpKey = "enableCatchUp"
fileprivate let enableStartOverKey = "enableStartOver"
fileprivate let enableTrickPlayKey = "enableTrickPlay"

public class OTTProgramAsset: OTTMediaAsset {
    
    /**  EPG channel identifier  */
    public var epgChannelId: Int64?
    /**  EPG identifier  */
    public var epgId: String?
    /**  Ralated media identifier  */
    public var relatedMediaId: Int64?
    /**  Unique identifier for the program  */
    public var crid: String?
    /**  Id of linear media asset  */
    public var linearAssetId: Int64?
    /**  Is CDVR enabled for this asset  */
    public var enableCdvr: Bool?
    /**  Is catch-up enabled for this asset  */
    public var enableCatchUp: Bool?
    /**  Is start over enabled for this asset  */
    public var enableStartOver: Bool?
    /**  Is trick-play enabled for this asset  */
    public var enableTrickPlay: Bool?
    
    public required init?(json: Any) {
        super.init(json: json)
        
        let jsonObj: JSON = JSON(json)
        
        self.epgChannelId = jsonObj[epgChannelIdKey].int64
        self.epgId = jsonObj[epgIdKey].string
        self.relatedMediaId = jsonObj[relatedMediaIdKey].int64
        self.crid = jsonObj[cridKey].string
        self.linearAssetId = jsonObj[linearAssetIdKey].int64
        self.enableCdvr = jsonObj[enableCdvrKey].bool
        self.enableCatchUp = jsonObj[enableCatchUpKey].bool
        self.enableStartOver = jsonObj[enableStartOverKey].bool
        self.enableTrickPlay = jsonObj[enableTrickPlayKey].bool
    }
}

// ===================================================================================================
// Copyright (C) 2018 Kaltura Inc.
//
// Licensed under the AGPLv3 license, unless a different license for a
// particular library is specified in the applicable library path.
//
// You may obtain a copy of the License at
// https://www.gnu.org/licenses/agpl-3.0.html
// ===================================================================================================

import Foundation
import SwiftyJSON

fileprivate let enableTrickPlayKey = "enableTrickPlay"

public class OTTLiveAsset: OTTMediaAsset {
    
    /** Is trick-play enabled for this asset  */
    var enableTrickPlay: Bool?
    
    public required init?(json: Any) {
        super.init(json: json)
        
        let jsonObj: JSON = JSON(json)
        self.enableTrickPlay = jsonObj[enableTrickPlayKey].bool
    }
}

// ===================================================================================================
// Copyright (C) 2022 Kaltura Inc.
//
// Licensed under the AGPLv3 license, unless a different license for a
// particular library is specified in the applicable library path.
//
// You may obtain a copy of the License at
// https://www.gnu.org/licenses/agpl-3.0.html
// ===================================================================================================

import Foundation
import SwiftyJSON

class OVPExternalMediaEntry: OVPEntry {
    
    var externalSourceType: String?
    
    let externalSourceTypeKey = "externalSourceType"
    
    required init?(json: Any) {
        super.init(json: json)
        
        let jsonObject = JSON(json)
        self.externalSourceType = jsonObject[externalSourceTypeKey].string
    }
    
}

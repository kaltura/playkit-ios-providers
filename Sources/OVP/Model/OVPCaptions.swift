// ===================================================================================================
// Copyright (C) 2022 Kaltura Inc.
//
// Licensed under the AGPLv3 license, unless a different license for a
// particular library is specified in the applicable library path.
//
// You may obtain a copy of the License at
// https://www.gnu.org/licenses/agpl-3.0.html
// ===================================================================================================

import SwiftyJSON

class OVPCaptions: OVPBaseObject {
    
    var label: String
    var language: String?
    var languageCode: String
    var webVttUrl: String
    var url: String?
    var format: String?
    
    let languageKey = "language"
    let languageCodeKey = "languageCode"
    let webVttUrlKey = "webVttUrl"
    let urlKey = "url"
    let formatKey = "format"
    let labelKey = "label"
    
    required init?(json: Any) {
        let jsonObject = JSON(json)
        
        guard let label = jsonObject[labelKey].string,
              let languageCode = jsonObject[languageCodeKey].string,
              let webVttUrl = jsonObject[webVttUrlKey].string else {
            return nil
        }
        
        self.label = label
        self.language = jsonObject[languageKey].string
        self.languageCode = languageCode
        self.webVttUrl = webVttUrl
        self.url = jsonObject[urlKey].string
        self.format = jsonObject[formatKey].string
    }
    
}

extension OVPCaptions: CustomStringConvertible {
    
    var description: String {
        return label + languageCode + webVttUrl
    }
    
}

// ===================================================================================================
// Copyright (C) 2017 Kaltura Inc.
//
// Licensed under the AGPLv3 license, unless a different license for a 
// particular library is specified in the applicable library path.
//
// You may obtain a copy of the License at
// https://www.gnu.org/licenses/agpl-3.0.html
// ===================================================================================================

import Foundation

@objc public class OTTAnalyticsPluginConfig: NSObject {
    
    let baseUrl: String
    let timerInterval: TimeInterval
    var disableMediaHit: Bool = false
    var disableMediaMark: Bool = false
    var isExperimentalLiveMediaHit: Bool = false
    var epgId: String?
    
    init(baseUrl: String,
         timerInterval: TimeInterval,
         disableMediaHit: Bool = false,
         disableMediaMark: Bool = false,
         isExperimentalLiveMediaHit: Bool = false,
         epgId: String? = nil) {
        self.baseUrl = baseUrl
        self.timerInterval = timerInterval
        self.disableMediaHit = disableMediaHit
        self.disableMediaMark = disableMediaMark
        self.isExperimentalLiveMediaHit = isExperimentalLiveMediaHit
        self.epgId = epgId
    }
}

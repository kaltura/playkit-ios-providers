//
//  PhoenixAnalyticsPluginConfig.swift
//  PlayKitProviders
//
//  Created by Nilit Danan on 11/16/18.
//

import Foundation

@objc public class PhoenixAnalyticsPluginConfig: OTTAnalyticsPluginConfig {
    
    let ks: String
    let partnerId: Int
    
    @objc public init(baseUrl: String,
                      timerInterval: TimeInterval,
                      ks: String,
                      partnerId: Int,
                      disableMediaHit: Bool = false,
                      disableMediaMark: Bool = false,
                      isExperimentalLiveMediaHit: Bool = false,
                      epgId: String? = nil) {
        self.ks = ks
        self.partnerId = partnerId
        super.init(baseUrl: baseUrl,
                   timerInterval: timerInterval,
                   disableMediaHit: disableMediaHit,
                   disableMediaMark: disableMediaMark,
                   isExperimentalLiveMediaHit: isExperimentalLiveMediaHit,
                   epgId: epgId)
    }
}

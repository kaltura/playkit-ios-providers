// ===================================================================================================
// Copyright (C) 2021 Kaltura Inc.
//
// Licensed under the AGPLv3 license, unless a different license for a
// particular library is specified in the applicable library path.
//
// You may obtain a copy of the License at
// https://www.gnu.org/licenses/agpl-3.0.html
// ===================================================================================================


import Foundation
import SwiftyJSON
import KalturaNetKit

class OVPBasePlaylistService {
    
    internal static func get(baseURL: String, ks: String, playlistId: String?) -> KalturaRequestBuilder? {
        
        if let request: KalturaRequestBuilder = KalturaRequestBuilder(url: baseURL, service: "playlist", action: "get") {
            
            let responseProfile = ["fields": "id,name,description,thumbnailUrl",
                                   "type": 1] as [String: Any]
            
            request
                .setBody(key: "ks", value: JSON(ks))
                .setBody(key: "responseProfile", value: JSON(responseProfile))
            
            if let playlistId = playlistId {
                request.setBody(key: "id", value: JSON(playlistId))
            }
            // else return nil?
            
            return request
        } else {
            return nil
        }
    }
    
    internal static func execute(baseURL: String, ks: String, playlistId: String?) -> KalturaRequestBuilder? {
        
        if let request: KalturaRequestBuilder = KalturaRequestBuilder(url: baseURL, service: "playlist", action: "execute") {
            
            let responseProfile = ["fields": "id,referenceId,name,description,thumbnailUrl,dataUrl,duration,msDuration,flavorParamsIds,mediaType,type,tags,dvrStatus,externalSourceType,status",
                                   "type": 1] as [String: Any]
            
            request
                .setBody(key: "ks", value: JSON(ks))
                .setBody(key: "responseProfile", value: JSON(responseProfile))
            
            if let playlistId = playlistId {
                request.setBody(key: "id", value: JSON(playlistId))
            }
            // else return nil?
            
            return request
        } else {
            return nil
        }
    }
    
}

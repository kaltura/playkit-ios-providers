//
//  OVPPlaylist.swift
//  PlayKitProviders
//
//  Created by Sergii Chausov on 01.09.2021.
//

import Foundation
import SwiftyJSON

class OVPPlaylist: OVPBaseObject {
    
    var id: String
    var name: String?
//    var description: String?
    var thumbnailUrl: String?
    
    let idKey = "id"
    let nameKey = "name"
    let descriptionKey = "description"
    let thumbnailUrlKey = "thumbnailUrl"
    
    required init?(json: Any) {
        
        let jsonObject = JSON(json)
        guard let id = jsonObject[idKey].string else {
            return nil
        }
        
        self.id = id
        self.name = jsonObject[nameKey].string
        self.thumbnailUrl = jsonObject[thumbnailUrlKey].string
    }
    
}

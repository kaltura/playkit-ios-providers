//
//  OVPMetadataList.swift
//  PlayKitProviders
//
//  Created by Nilit Danan on 11/18/20.
//

import Foundation
import SwiftyJSON

class OVPMetadataList: OVPBaseObject {

    var objects: [OVPMetadata]?
    
    required init?(json: Any) {
        
        let jsonObject = JSON(json)
        
        if let objects = jsonObject["objects"].array {
            var parsedObjects: [OVPMetadata] = [OVPMetadata]()
            for object in objects {
                if let ovpMetadata: OVPMetadata = OVPMultiResponseParser.parseSingleItem(json: object) as? OVPMetadata {
                    parsedObjects.append(ovpMetadata)
                }
            }
            self.objects = parsedObjects
        }
    }
}

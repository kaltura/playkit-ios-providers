//
//  OVPBaseEntryList.swift
//  PlayKitProviders
//
//  Created by Nilit Danan on 11/18/20.
//

import Foundation
import SwiftyJSON

class OVPBaseEntryList: OVPBaseObject {
    
    var objects: [OVPEntry]?
    
    required init?(json: Any) {
        
        let jsonObject = JSON(json)
        
        if let objects = jsonObject["objects"].array {
            var parsedObjects: [OVPEntry] = [OVPEntry]()
            for object in objects {
                if let ovpEntry: OVPEntry = OVPMultiResponseParser.parseSingleItem(json: object) as? OVPEntry {
                    parsedObjects.append(ovpEntry)
                }
            }
            self.objects = parsedObjects
        }
    }
}

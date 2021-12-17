// ===================================================================================================
// Copyright (C) 2021 Kaltura Inc.
//
// Licensed under the AGPLv3 license, unless a different license for a
// particular library is specified in the applicable library path.
//
// You may obtain a copy of the License at
// https://www.gnu.org/licenses/agpl-3.0.html
// ===================================================================================================
//

import Foundation
import KalturaNetKit
import PlayKit

@objc public class OVPPlaylistProvider: BasicProvider, PlaylistProvider {
    
    struct OVPPlaylistLoaderInfo {
        var sessionProvider: SessionProvider
        var playlistId: String?
        var mediaAssets: [OVPMediaAsset]?
        var executor: RequestExecutor
        var apiServerURL: String {
            return self.sessionProvider.serverURL + "/api_v3"
        }
    }
    
    @objc public var mediaAssets: [OVPMediaAsset]?
    @discardableResult
    @nonobjc public func set(mediaAssets: [OVPMediaAsset]?) -> Self {
        self.mediaAssets = mediaAssets
        return self
    }
    
    @objc public var playlistId: String?
    
    @discardableResult
    @nonobjc public func set(playlistId: String?) -> Self {
        self.playlistId = playlistId
        return self
    }
    
    public func loadPlaylist(callback: @escaping (PKPlaylist?, Error?) -> Void) {
        
        // session provider is required in order to have the base url and the partner id
        guard let sessionProvider = self.sessionProvider else {
            PKLog.debug("Proivder must have session info")
            callback(nil, OVPMediaProviderError.invalidParam(paramName: "sessionProvider"))
            return
        }
        
        guard self.mediaAssets != nil || self.playlistId != nil else {
            PKLog.debug("Proivder must have playlistId or mediaAssets")
            callback(nil, OVPMediaProviderError.invalidParams)
            return
        }
        
        //building the loader info which contain all required fields
        let loaderInfo = OVPPlaylistLoaderInfo(sessionProvider: sessionProvider,
                                               playlistId: self.playlistId,
                                               mediaAssets: self.mediaAssets,
                                               executor: executor ?? KNKRequestExecutor.shared)
        
        if let playlistId = self.playlistId, !playlistId.isEmpty {
            self.startLoading(loadInfo: loaderInfo, callback: callback)
        } else if let assets = self.mediaAssets, !assets.isEmpty {
            self.startLoadingByIds(loadInfo: loaderInfo, callback: callback)
        } else {
            callback(nil, OVPMediaProviderError.invalidParams)
        }
    }
    
    func startLoading(loadInfo: OVPPlaylistLoaderInfo, callback: @escaping (PKPlaylist?, Error?) -> Void) -> Void {
        
        loadInfo.sessionProvider.loadKS { (resKS, error) in
            
            let mrb: KalturaMultiRequestBuilder? = KalturaMultiRequestBuilder(url: loadInfo.apiServerURL)?.setOVPBasicParams()
            
            var ks: String? = nil
            
            // checking if we got ks from the session, otherwise we should work as anonymous
            if let data = resKS, data.isEmpty == false {
                ks = data
            } else {
                // Adding "startWidgetSession" request in case we don't have ks
                let loginRequestBuilder = OVPSessionService.startWidgetSession(baseURL: loadInfo.apiServerURL,
                                                                               partnerId: loadInfo.sessionProvider.partnerId)
                if let req = loginRequestBuilder {
                    mrb?.add(request: req)
                    // Changing the ks to this format in order to use it as a multi request (forward from the first response)
                    ks = "{1:result:ks}"
                }
            }
            
            // Check if we don't have forward token and not real token we can't continue
            guard let token = ks else {
                PKLog.debug("can't find ks and can't request as anonymous ks (WidgetSession)")
                callback(nil, OVPMediaProviderError.invalidKS)
                return
            }
            
            // Request for Entry data
            let getPlaylist = OVPBasePlaylistService.get(baseURL: loadInfo.apiServerURL,
                                                         ks: token,
                                                         playlistId: loadInfo.playlistId)
            
            let executePlaylist = OVPBasePlaylistService.execute(baseURL: loadInfo.apiServerURL,
                                                                 ks: token,
                                                                 playlistId: loadInfo.playlistId)
            
            guard let req1 = getPlaylist, let req2 = executePlaylist else {
                callback(nil, OVPMediaProviderError.invalidParams)
                return
            }
            
            // Combining all requests to single multi request
            mrb?.add(request: req1)
                .add(request: req2)
                .set(completion: { (dataResponse: Response) in
                    
                    PKLog.debug("Response:\nStatus Code: \(dataResponse.statusCode)\nError: \(dataResponse.error?.localizedDescription ?? "")\nData: \(dataResponse.data ?? "")")
                    
                    if let error = dataResponse.error {
                        PKLog.debug("Got an error.")
                        // If error is of type `PKError` pass it as `NSError` else pass the `Error` object.
                        callback(nil, (error as? PKError)?.asNSError ?? error)
                        return
                    }
                    
                    guard let data = dataResponse.data else {
                        PKLog.debug("Didn't get response data.")
                        callback(nil, OVPMediaProviderError.invalidResponse)
                        return
                    }
                    
                    let responses: [OVPBaseObject] = OVPMultiResponseParser.parse(data: data)
                    
                    // At leat we need to get response of Playlist and Playlist media items, on anonymous we will have additional startWidgetSession call
                    guard responses.count >= 2 else {
                        PKLog.debug("Didn't get response for all requests.")
                        callback(nil, OVPMediaProviderError.invalidResponse)
                        return
                    }
                    
                    var ovpPlaylist: OVPPlaylist?
                    var ovpEntryList: [OVPEntry]?
                    var ovpError: OVPError?
                    
                    for response in responses {
                        switch response {
                        case is OVPList:
                            if let list = response as? OVPList {
                                ovpEntryList = list.objects as? [OVPEntry]
                            }
                        case is OVPPlaylist:
                            ovpPlaylist = response as? OVPPlaylist
                        case is OVPError:
                            ovpError = response as? OVPError
                        default:
                            break
                        }
                    }
                    
                    if let error = ovpError {
                        PKLog.debug("Response returned with an error.")
                        callback(nil, OVPMediaProviderError.serverError(code: error.code ?? "", message: error.message ?? "").asNSError)
                        return
                    }
                    
                    guard let playlistData = ovpPlaylist,
                        let playlistItems = ovpEntryList,
                        !playlistItems.isEmpty
                        else {
                            PKLog.debug("Response is not containing playlist info or playlist items")
                            callback(nil, OVPMediaProviderError.invalidResponse)
                            return
                    }
                    
                    let entries: [PKMediaEntry] = playlistItems.map {
                        let entry = PKMediaEntry($0.id,
                                                 sources: nil,
                                                 duration: $0.duration)
                        
                        entry.name = $0.name
                        entry.thumbnailUrl = $0.thumbnailUrl
                        return entry
                    }
                    
                    let playlist = PKPlaylist(id: playlistData.id,
                                              name: playlistData.name,
                                              thumbnailUrl: playlistData.thumbnailUrl,
                                              medias: entries)
                    
                    callback(playlist, nil)
                })
            
            // Building and executing multi request.
            if let request = mrb?.build() {
                PKLog.debug("Sending requests: \(mrb?.description ?? "")")
                loadInfo.executor.send(request: request)
            } else {
                callback(nil, OVPMediaProviderError.invalidParams)
            }
        }
    }
    
    func startLoadingByIds(loadInfo: OVPPlaylistLoaderInfo, callback: @escaping (PKPlaylist?, Error?) -> Void) -> Void {
        
        loadInfo.sessionProvider.loadKS { (resKS, error) in
            
            let mrb: KalturaMultiRequestBuilder? = KalturaMultiRequestBuilder(url: loadInfo.apiServerURL)?.setOVPBasicParams()
            
            var ks: String? = nil
            
            // checking if we got ks from the session, otherwise we should work as anonymous
            if let data = resKS, data.isEmpty == false {
                ks = data
            } else {
                // Adding "startWidgetSession" request in case we don't have ks
                let loginRequestBuilder = OVPSessionService.startWidgetSession(baseURL: loadInfo.apiServerURL,
                                                                               partnerId: loadInfo.sessionProvider.partnerId)
                if let req = loginRequestBuilder {
                    mrb?.add(request: req)
                    // Changing the ks to this format in order to use it as a multi request (forward from the first response)
                    ks = "{1:result:ks}"
                }
            }
            
            // Check if we don't have forward token and not real token we can't continue
            guard let token = ks else {
                PKLog.debug("can't find ks and can't request as anonymous ks (WidgetSession)")
                callback(nil, OVPMediaProviderError.invalidKS)
                return
            }
            
            guard let mediaAssets = loadInfo.mediaAssets else {
                callback(nil, OVPMediaProviderError.invalidParam(paramName: "loadInfo.mediaAssets"))
                return
            }
            
            for asset in mediaAssets {
                if let request = OVPBaseEntryService.list(baseURL: loadInfo.apiServerURL,
                                                          ks: token,
                                                          entryID: asset.id,
                                                          referenceId: asset.referenceId) {
                    mrb?.add(request: request)
                }
            }
            
            mrb?.set(completion: { (dataResponse: Response) in
                
                PKLog.debug("Response:\nStatus Code: \(dataResponse.statusCode)\nError: \(dataResponse.error?.localizedDescription ?? "")\nData: \(dataResponse.data ?? "")")
                
                if let error = dataResponse.error {
                    PKLog.debug("Got an error.")
                    // If error is of type `PKError` pass it as `NSError` else pass the `Error` object.
                    callback(nil, (error as? PKError)?.asNSError ?? error)
                    return
                }
                
                guard let data = dataResponse.data else {
                    PKLog.debug("Didn't get response data.")
                    callback(nil, OVPMediaProviderError.invalidResponse)
                    return
                }
                
                let responses: [OVPBaseObject] = OVPMultiResponseParser.parse(data: data)
                
                // At leat we need to get response of Playlist and Playlist media items, on anonymous we will have additional startWidgetSession call
                guard responses.count >= 2 else {
                    PKLog.debug("Didn't get response for all requests.")
                    callback(nil, OVPMediaProviderError.invalidResponse)
                    return
                }
                
                var ovpEntryList: [OVPEntry] = []
                
                for response in responses {
                    switch response {
                    case is OVPBaseEntryList:
                        if let entryList = response as? OVPBaseEntryList,
                           let items = entryList.objects {
                            ovpEntryList.append(contentsOf: items)
                        }
                    case is OVPError:
                        if let error = response as? OVPError {
                            let errorDescription = OVPMediaProviderError.serverError(code: error.code ?? "", message: error.message ?? "").asNSError.localizedDescription
                            PKLog.error("Invalid Entry. Error: \(errorDescription)")
                            
                            if let item = OVPEntry(json: ["id": "EMPTY-ID", "name": "Unnamed"]) {
                                ovpEntryList.append(item)
                            }
                        }
                    default:
                        break
                    }
                }
                
                if ovpEntryList.isEmpty {
                    PKLog.debug("Response is not containing playlist info or playlist items")
                    callback(nil, OVPMediaProviderError.invalidResponse)
                    return
                }
                
                let entries: [PKMediaEntry] = ovpEntryList.map {
                    let entry = PKMediaEntry($0.id,
                                             sources: nil,
                                             duration: $0.duration)
                    
                    entry.name = $0.name
                    entry.thumbnailUrl = $0.thumbnailUrl
                    return entry
                }
                
                let playlist = PKPlaylist(id: nil,
                                          name: nil,
                                          thumbnailUrl: nil,
                                          medias: entries)
                
                callback(playlist, nil)
            })
            
            // Building and executing multi request.
            if let request = mrb?.build() {
                PKLog.debug("Sending requests: \(mrb?.description ?? "")")
                loadInfo.executor.send(request: request)
            } else {
                callback(nil, OVPMediaProviderError.invalidParams)
            }
        }
    }
    
    public func cancel() {
        
        
    }
    
}

@objc public class OVPMediaAsset: NSObject {
    
    var id: String?
    var referenceId: String?
    
    public init(id: String? = nil, referenceId: String? = nil) {
        self.id = id
        self.referenceId = referenceId
    }
    
}

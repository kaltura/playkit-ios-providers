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

@objc public class PhoenixPlaylistProvider: BasicProvider, PlaylistProvider {
    
    struct PhoenixPlaylistLoaderInfo {
        var sessionProvider: SessionProvider
        var mediaAssets: [OTTPlaylistAsset]?
        var executor: RequestExecutor
        var apiServerURL: String {
            return self.sessionProvider.serverURL + ""
        }
    }
    
    @objc public var mediaAssets: [OTTPlaylistAsset]?
    @discardableResult
    @nonobjc public func set(mediaAssets: [OTTPlaylistAsset]?) -> Self {
        self.mediaAssets = mediaAssets
        return self
    }
    
    public func loadPlaylist(callback: @escaping (PKPlaylist?, Error?) -> Void) {
        // session provider is required in order to have the base url and the partner id
        guard let sessionProvider = self.sessionProvider else {
            PKLog.debug("Provider must have session info")
            callback(nil, PhoenixMediaProviderError.invalidInputParam(param: "sessionProvider").asNSError)
            return
        }
        
        guard self.mediaAssets != nil else {
            PKLog.debug("Provider must have playlistId or mediaAssets")
            callback(nil, PhoenixMediaProviderError.invalidInputParam(param: "mediaAssets").asNSError)
            return
        }
        
        // Building the loader info which contains all required fields.
        let loaderInfo = PhoenixPlaylistLoaderInfo(sessionProvider: sessionProvider,
                                                   mediaAssets: self.mediaAssets,
                                                   executor: executor ?? KNKRequestExecutor.shared)
        
        self.startLoadingByIds(loadInfo: loaderInfo, callback: callback)
    }
    
    func startLoadingByIds(loadInfo: PhoenixPlaylistLoaderInfo, callback: @escaping (PKPlaylist?, Error?) -> Void) -> Void {
        
        loadInfo.sessionProvider.loadKS { (resKS, error) in
            
            let mrb: KalturaMultiRequestBuilder? = KalturaMultiRequestBuilder(url: loadInfo.apiServerURL)?.setOTTBasicParams()
            
            var ks: String
            
            // Checking if we got ks from the session, otherwise we should work as anonymous.
            if let data = resKS, data.isEmpty == false {
                ks = data
            } else {
                let anonymousLogin = OTTUserService.anonymousLogin(baseURL: loadInfo.sessionProvider.serverURL,
                                                                   partnerId: loadInfo.sessionProvider.partnerId)
                
                if let anonymousLoginRequest = anonymousLogin {
                    mrb?.add(request: anonymousLoginRequest)
                }
                
                ks = "{1:result:ks}"
            }
            
            guard let mediaAssets = loadInfo.mediaAssets else {
                callback(nil, PhoenixMediaProviderError.invalidInputParam(param: "loadInfo.mediaAssets"))
                return
            }
            
            for asset in mediaAssets {
                if let assetId = asset.id, let refType = asset.assetReferenceType,
                   let type = PhoenixMediaProvider.toAPIType(type: refType),
                   let request = OTTAssetService.getMetaData(baseURL: loadInfo.apiServerURL,
                                                             ks: ks,
                                                             assetId: assetId,
                                                             refType: type) {
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
                    callback(nil, PhoenixMediaProviderError.emptyResponse.asNSError)
                    return
                }
                
                var responses: [OTTBaseObject] = []
                
                do {
                    responses = try OTTMultiResponseParser.parse(data: data)
                } catch {
                    callback(nil, PhoenixMediaProviderError.unableToParseData(data: data).asNSError)
                }
                
                // At leat we need to get response of Playlist media items, on anonymous we will have additional startWidgetSession call
                guard responses.count >= 1 else {
                    PKLog.debug("Didn't get response for all requests.")
                    callback(nil, OVPMediaProviderError.invalidResponse)
                    return
                }
                
                var ottEntryList: [OTTMediaAsset] = []
                
                for response in responses {
                    switch response {
                    case is OTTMediaAsset:
                        if let asset = response as? OTTMediaAsset {
                            ottEntryList.append(asset)
                        }
                    case is OTTError:
                        if let error = response as? OTTError {
                            let errorDescription = OVPMediaProviderError.serverError(code: error.code ?? "", message: error.message ?? "").asNSError.localizedDescription
                            PKLog.error("Invalid Entry. Error: \(errorDescription)")
                            
                            if let item = OTTMediaAsset(json: ["id": "EMPTY-ID", "name": "Unnamed"]) {
                                ottEntryList.append(item)
                            }
                        }
                    default:
                        break
                    }
                }
                
                if ottEntryList.isEmpty {
                    PKLog.debug("Response is not containing playlist info or playlist items")
                    callback(nil, OVPMediaProviderError.invalidResponse)
                    return
                }
                
                let entries: [PKMediaEntry] = ottEntryList.map {
                    let entry = PKMediaEntry("\($0.id ?? 0)",
                                             sources: nil,
                                             duration: Double($0.mediaFiles.first?.duration ?? 0))
                    
                    entry.name = $0.name
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

@objc public class OTTPlaylistAsset: NSObject {
    
    var id: String?
    var assetReferenceType: AssetReferenceType?
    
    public init(id: String? = nil, assetReferenceType: AssetReferenceType? = nil) {
        self.id = id
        self.assetReferenceType = assetReferenceType
    }
    
}

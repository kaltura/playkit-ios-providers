//
//  BasicProvider.swift
//  PlayKitProviders
//
//  Created by Sergii Chausov on 30.08.2021.
//

import Foundation
import KalturaNetKit

@objc public class BasicProvider: NSObject {
 
    @objc public var sessionProvider: SessionProvider?
    
    @objc public var uiconfId: NSNumber?
    @objc public var referrer: String?
    public var executor: RequestExecutor?
    
    @objc public override init() {}
    
    @objc public init(_ sessionProvider: SessionProvider) {
        self.sessionProvider = sessionProvider
    }
    
    /**
     session provider - which resposible for the ks, prtner id, and base server url
     */
    @discardableResult
    @nonobjc public func set(sessionProvider: SessionProvider?) -> Self {
        self.sessionProvider = sessionProvider
        return self
    }
    
    /**
     uiconfId - UI Configuration id
     */
    @discardableResult
    @nonobjc public func set(uiconfId: NSNumber?) -> Self {
        self.uiconfId = uiconfId
        return self
    }
    
    /// set the provider referrer
    ///
    /// - Parameter referrer: the app referrer
    /// - Returns: Self
    @discardableResult
    @nonobjc public func set(referrer: String?) -> Self {
        self.referrer = referrer
        return self
    }
    
    /**
     executor - which resposible for the network, it can be set to
     */
    @discardableResult
    @nonobjc public func set(executor: RequestExecutor?) -> Self {
        self.executor = executor
        return self
    }
}

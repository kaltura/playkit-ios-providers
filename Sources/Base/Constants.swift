//
//  Constants.swift
//  PlayKitProviders
//
//  Created by Nilit Danan on 11/17/20.
//

import Foundation

public let ProviderServerErrorCodeKey: String = "code"
public let ProviderServerErrorMessageKey: String = "message"

@objc public class PKProvidersErrorUserInfoKey: NSObject {
    
    @objc public static let ServerErrorCodeKey: NSString = NSString(string: ProviderServerErrorCodeKey)
    @objc public static let ServerErrorMessageKey: NSString = NSString(string: ProviderServerErrorMessageKey)
}

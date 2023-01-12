![Swift 3.0+](https://img.shields.io/badge/Swift-3.0+-orange.svg)
[![CI Status](https://github.com/kaltura/playkit-ios-providers/actions/workflows/ci.yml/badge.svg)](https://github.com/kaltura/playkit-ios-providers/actions/workflows/ci.yml)
[![Version](https://img.shields.io/cocoapods/v/PlayKitProviders.svg?style=flat)](https://cocoapods.org/pods/PlayKitProviders)
[![License](https://img.shields.io/cocoapods/l/PlayKitProviders.svg?style=flat)](https://cocoapods.org/pods/PlayKitProviders)
[![Platform](https://img.shields.io/cocoapods/p/PlayKitProviders.svg?style=flat)](https://cocoapods.org/pods/PlayKitProviders)

# playkit-ios-providers

This plugin gives seamless access of your medias ingested in Kaltura backend with [Playkit](https://github.com/kaltura/playkit-ios) or [Kaltura-Player](https://github.com/kaltura/kaltura-player-ios).
By using this plugin, developers don't need to care about Network calls, Thread Management etc. Simply pass the media Id and respective KS (Kaltura Session Token) and you are good to go for the playback.

Providers are designed for Kaltura OVP or Kaltura OTT customers. One can have a question what is the difference between OVP and OTT !
 
OVP BE takes care of storage, transcoding, delivery, packaging and distribution. It is media preparation part.

OTT BE takes care of Auth, Subscription and other distribution related services.

Apart from this, plugin provides Concurrency measurement feature. Plugin provides `OTT Analytics` for this.

For more info, please connect with Kaltura CSM.

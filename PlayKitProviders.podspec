
suffix = '.0000'   # Dev mode
# suffix = ''       # Release

Pod::Spec.new do |s|
  
  s.name             = 'PlayKitProviders'
  s.version          = '1.17.0' + suffix
  s.summary          = 'PlayKitProviders -- Providers framework for iOS'
  s.homepage         = 'https://github.com/kaltura/playkit-ios-providers'
  s.license          = { :type => 'AGPLv3', :file => 'LICENSE' }
  s.author           = { 'Kaltura' => 'community@kaltura.com' }
  s.source           = { :git => 'https://github.com/kaltura/playkit-ios-providers.git', :tag => 'v' + s.version.to_s }
  s.swift_version     = '5.0'

  s.ios.deployment_target = '9.0'
  s.tvos.deployment_target = '9.0'

  s.source_files = 'Sources/**/*'
  
  s.dependency 'PlayKit/AnalyticsCommon', '~> 3.24'
    
  s.dependency 'KalturaNetKit', '~> 1.5'
  s.dependency 'PlayKitUtils', '~> 0.5'
  s.dependency 'SwiftyXMLParser', '5.0.0'
end


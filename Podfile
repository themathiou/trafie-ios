platform :ios, '9.0'
use_frameworks!

target 'trafie' do
    pod 'RealmSwift', git: 'https://github.com/realm/realm-cocoa.git', branch: 'master', submodules: true
    pod 'ALCameraViewController'
    pod 'PromiseKit/CorePromise', :git => 'https://github.com/mxcl/PromiseKit', :branch => 'swift-3.0'
    pod 'Alamofire', '4.0.0'
    pod 'Google/Analytics'
    pod 'Kingfisher', '~> 3.0'
    pod 'KYNavigationProgress'
    pod 'SwiftyJSON', :git => 'https://github.com/appsailor/SwiftyJSON.git', :branch => 'swift3'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end

#target 'trafieTests' do
#end

#target 'trafieUITests' do
#end

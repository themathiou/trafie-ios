platform :ios, '9.0'
use_frameworks!

target 'trafie' do
    pod 'Realm'
    pod 'RealmSwift'
    pod 'PromiseKit/CorePromise'
    pod 'Alamofire', '4.0.0'
    pod 'Google/Analytics'
    pod 'Kingfisher', '3.1.0'
    pod 'KYNavigationProgress'
    pod 'SwiftyJSON'
    pod 'UICircularProgressRing'
    pod 'ALCameraViewController'
    pod 'Whisper', :git => 'https://github.com/hyperoslo/Whisper.git', :branch => 'swift-3'
    pod 'FacebookShare', :git => 'https://github.com/facebook/facebook-sdk-swift'
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

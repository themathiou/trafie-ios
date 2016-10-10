# README #

### What is this repository for? ###

* iOS Swift version of [trafie](https://www.trafie.com)

### How do I get set up? ###

* Summary of set up
* Configuration
* Dependencies
* Database configuration
* How to run tests
* Deployment instructions

### CocoaPods ###
platform :iOS, ‘9.0’
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
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end

### Contribution guidelines ###

* Writing tests
* Code review
* Other guidelines

### How Set Ready for Release ###

* Target Production URL
* Enable Google Analytics
* Run Manual Tests.

### Steps to upload on AppStore ###

* Product > Archive
* Validate
* Upload to AppStore. (demo user: demouser@trafie.com , demo123)

### Who do I talk to? ###

* Mathioudakis Thodoris
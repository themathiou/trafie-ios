# README #

### What is this repository for? ###

* iOS Swift version of [trafie](https://www.trafie.com)

### How Set Ready for Release ###

* Target Production URL
* Enable Google Analytics
* Run Manual Tests.

### How do I get set up? ###

* Summary of set up
* Configuration
* Dependencies
* Database configuration
* How to run tests
* Deployment instructions

### CocoaPods ###
platform :iOS, ‘8.0’
use_frameworks!

target 'trafie' do
    pod 'RealmSwift'
    pod 'PromiseKit', '~> 3.0'
    pod 'Alamofire', '~> 3.4'
    pod 'DZNEmptyDataSet', '~> 1.7'
    pod 'AKPickerView-Swift', '~> 1.0'
    pod 'Google/Analytics'
    pod 'Kingfisher', '~> 2.4'
    pod 'ALCameraViewController'
end

### Contribution guidelines ###

* Writing tests
* Code review
* Other guidelines

### Who do I talk to? ###

* Mathioudakis Thodoris
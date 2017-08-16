project 'Cru.xcodeproj'

# Uncomment this line to define a global platform for your project
platform :ios, '9.0'

# Uncomment this line if you're using Swift
use_frameworks!

def cru_pods
    pod 'SideMenu', '2.2.0'
    pod 'Firebase/Messaging'
    pod 'DatePickerCell'
    pod 'LocationPickerViewController', '3.0.0'
    pod 'IQKeyboardManagerSwift', '4.0.8'
    pod 'SwiftValidator', :git => 'https://github.com/jpotts18/SwiftValidator.git', :branch => 'master'
    pod 'MRProgress'
    pod 'Alamofire', '~> 4.3'
    pod 'RadioButton'
    pod 'ActionSheetPicker-3.0'
    pod 'DZNEmptyDataSet'
    pod 'ImageLoader'
    pod 'HTMLReader', '~> 1.0'
    pod 'SwiftyJSON', '3.1.4'
    pod 'LocationPicker'
    pod 'GooglePlaces'
    pod 'GooglePlacePicker'
    pod 'GoogleMaps'
    pod 'ReadabilityKit'
    pod 'XLPagerTabStrip', '~> 7.0'
    pod 'YouTubePlayer'
    pod 'UIScrollView-InfiniteScroll', '~> 1.0'
    pod 'DropDown'
end

def crash_monitor
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'Appsee'
end

target 'Cru' do
    cru_pods
    crash_monitor
end

target 'CruTests' do
    cru_pods
    crash_monitor
end



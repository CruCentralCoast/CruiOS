xcodeproj 'Cru.xcodeproj'

# Uncomment this line to define a global platform for your project
platform :ios, '8.0'

# Uncomment this line if you're using Swift
use_frameworks!

def cru_pods
    pod 'SideMenu', '~> 0.1'
    pod 'Google/CloudMessaging', '1.3.2'
    pod 'DatePickerCell'
    pod 'LocationPickerViewController', '~> 1.2'
    pod 'IQKeyboardManagerSwift', '3.3.4'
    pod 'SwiftValidator'
    pod 'MRProgress'
    pod 'Alamofire', '~> 3.0'
    pod 'RadioButton'
    pod 'ActionSheetPicker-3.0'
    pod 'DZNEmptyDataSet'
    pod 'ImageLoader'
    pod 'HTMLReader', '~> 1.0'
    pod 'SwiftyJSON', '~> 2.3.0'
    pod 'PagedArray', '~> 0.2'
    pod 'LocationPicker'
    pod 'GooglePlaces'
    pod 'GooglePlacePicker'
    pod 'GoogleMaps'
    pod 'NVActivityIndicatorView', '~> 2.11'
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



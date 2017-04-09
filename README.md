# Cru Central Coast Mobile App
iOS mobile app for Cru Central Coast

##How to Build
* Install CocoaPods
* Run the command `pod install` in the project directory
* Open the `Podfile` in the CruiOS directory and add a comment to the line `pod 'Google/CloudMessaging', '1.3.2'`
* Run `pod install` again
* Open the `Podfile` in the CruiOS directory and remove the comment you just put in
* Run `pod install` again
* Follow the instructions below

### Notes
##### Whenever a New Pod is Installed
* In XCode, open `Pods-Cru.debug.xcconfig` in the Pods folder under the Cru project
* In the `OTHER_LDFLAGS` section, remove `-force_load $(PODS_ROOT)/GoogleUtilities/Libraries/libGTM_NSData+zlib.a`. It should be the last entry.
* Open `Pods-Cru.release.xcconfig` and remove the same code.

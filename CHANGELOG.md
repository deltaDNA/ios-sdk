# Change Log

## [4.11.0](https://github.com/deltaDNA/ios-sdk/releases/tag/4.11.0) (YYYY-MM-DD)
### Added
- Support for cross promotion.
- Support for image message store action.

## [4.10.3](https://github.com/deltaDNA/ios-sdk/releases/tag/4.10.3) (2018-11-26)
### Fixed
- Don't use cached Engage responses for invalid/deleted/disabled Engagements.
- Crash when failing to retrieve device locale information on SDK initialisation.

## [4.10.2](https://github.com/deltaDNA/ios-sdk/releases/tag/4.10.2) (2018-11-07)
### Fixed
- Missing fields in ddnaEventTriggeredAction event.

## [4.10.1](https://github.com/deltaDNA/ios-sdk/releases/tag/4.10.1) (2018-09-20)
### Fixed
- Missing device identifiers for new iPads and iPhones.

## [4.10.0](https://github.com/deltaDNA/ios-sdk/releases/tag/4.10.0) (2018-08-22)
### Added
- Sends IDFA with the ForgetMe event if used with Smartads.

## [4.9.0](https://github.com/deltaDNA/ios-sdk/releases/tag/4.9.0) (2018-08-07)
### Changed
- Minimum iOS target set to iOS 9.
- `recordEvent:` methods return a `DDNAEventAction` object, which can be used with event-triggered campaigns.
- Engage cache expires entries by default after 12 hours.  This can be controlled in the sdk settings.

### Added
- Added support for event-triggered campaigns.

## [4.8.1](https://github.com/deltaDNA/ios-sdk/releases/tag/4.8.1) (2018-07-27)
### Fixed
- Infinite loop when setting push notification token.

## [4.8.0](https://github.com/deltaDNA/ios-sdk/releases/tag/4.8.0) (2018-05-18)
### Added
- ForgetMe API notifies the platform the user no longer wishes to be tracked and stops the sdk sending further events.
- Improvements to image message caching.

## [4.7.0](https://github.com/deltaDNA/ios-sdk/releases/tag/4.7.0) (2018-04-17)
### Changed
- Automatic ad registration when using ads.
- Added `DDNAEngageFactory` to simplfy Engage requests.

## [4.6.3](https://github.com/deltaDNA/ios-sdk/releases/tag/4.6.3) (2018-04-03)
### Fixed
- Missing locale in engage requests.

## [4.6.2](https://github.com/deltaDNA/ios-sdk/releases/tag/4.6.2) (2018-02-06)
### Changed
- Collect and Engage URLs will be forced to use HTTPS.

## [4.6.1](https://github.com/deltaDNA/ios-sdk/releases/tag/4.6.1) (2017-10-30)
### Fixed
- Better compatibility with ObjectiveC++ code.

## [4.6.0](https://github.com/deltaDNA/ios-sdk/releases/tag/4.6.0) (2017-10-23)
### Changed
- Min version to iOS 8.
- tvOS example with Swift 4.
- Deprecated DDNA_DEBUG for controlling logging.
- Updated device name mappings.
- Report platform as 'IOS' by default.

### Added
- Control the log verbosity directly on the sdk with +setLogLevel on DDNASDK.  If DDNA_DEBUG=1 is still set, it will override setLogLevel.

## [4.5.0](https://github.com/deltaDNA/ios-sdk/releases/tag/4.5.0) (2017-06-27)
### Added
- Send an imageMessageAction event when interacting with image messages.

## [4.3.0](https://github.com/deltaDNA/ios-sdk/releases/tag/4.3.0) (2017-03-13)
### Added
- The platform can now be overridden.  Set the property before calling Start.

### Changed
- Removed previously deprecated Engage and Image Message methods.

## [4.2.4](https://github.com/deltaDNA/ios-sdk/releases/tag/4.2.4) (2016-09-29)
### Added
- Support iPhone 7 device names.

### Fixed
- TARGET_TV_OS was always defined.

## [4.2.3](https://github.com/deltaDNA/ios-sdk/releases/tag/4.2.3) (2016-09-13)
### Fixed
- Support for Xcode 8.

## [4.2.2](https://github.com/deltaDNA/ios-sdk/releases/tag/4.2.2) (2016-09-07)
### Fixed
- Added resources for CocoaPods.

## [4.2.1](https://github.com/deltaDNA/ios-sdk/releases/tag/4.2.1) (2016-09-06)
### Fixed
- Currency conversion helper on tvOS.

## [4.2.0](https://github.com/deltaDNA/ios-sdk/releases/tag/4.2.0) (2016-09-05)
### Added
- Helper in DDNAProduct for converting currencies from a decimal number representation.

### Fixed
- Crash when reported device locale is null.
- Time zone offsets being misreported for some time zones.

## [4.1.2](https://github.com/deltaDNA/ios-sdk/releases/tag/4.1.2) (2016-05-27)
### Added
- Post notification when a new session is started.

## [4.1.1](https://github.com/deltaDNA/ios-sdk/releases/tag/4.1.1) (2016-05-06)
### Fixed
- Replaced iOS8 method `NSString (BOOL)containsString:(NSString *)` with own method.

## [4.1.0](https://github.com/deltaDNA/ios-sdk/releases/tag/4.1.0) (2016-04-29)
### Added
- Additional API for Engagements `-requestEngagement:engagementHandler` allows the caller to query the `DDNAEngagement` object directly for the parameters returned by the Engage service.  See the [README](README.md) for an example.
- Will automatically generate a new session id if the app has been in the background for more than 5 minutes.  This behaviour can be configured from the settings.

### Changed
- The `DDNAPopup` protocol and `DDNABasicPopup` have been deprecated and replaced by `DDNAImageMessage`.  This better matches the terminology used in the deltaDNA platform. The `DDNAImageMessage` is created from the `DDNAEngagement` object.
- The `-requestImageMesaage:` methods are also deprecated, use `-requestEngagement:engagementHandler` with a `DDNAImageMessage` instead.
- The automated event uploading no longer retries by default on a network connection error, instead it relies on the background timer to try again later.  The default timeout has also been increased.

## [4.0.1](https://github.com/deltaDNA/ios-sdk/releases/tag/4.0.1) (2016-03-29)
### Added
- Support event deduplication with eventUUID field.

### Changed
- Limit event upload size to 1MB.

### Fixed
- Local uses separate country and language codes to handle unsupported values better.

## [4.0.0](https://github.com/deltaDNA/ios-sdk/releases/tag/4.0.0) (2016-03-14)
Initial version 4.0 release.

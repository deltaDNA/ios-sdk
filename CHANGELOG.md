# Change Log

## [Unreleased]() (unknown)
### Added
- Additional API for Engagements `-requestEngagement:engagementHandler` allows the caller to query the `DDNAEngagement` object directly for the parameters returned by the Engage service.  See the [README](README.md) for an example.
- Will automatically generate a new session id if the app has been in the background for more than 5 minutes.  This behaviour can be configured from the settings.

### Changed
- The `DDNAPopup` protocol and `DDNABasicPopup` have been deprecated and replaced by `DDNAImageMessage`.  This better matches the terminology used in the deltaDNA platform. The `DDNAImageMessage` is created from the `DDNAEngagement` object.
- The `-requestImageMesaage:` methods are also deprecated, use `-requestEngagement:engagementHandler` with a `DDNAImageMessage` instead.

## [4.0.1](https://github.com/deltaDNA/ios-sdk/releases/tag/4.0.1) (2016-03-29)
### Added
- Support event deduplication with eventUUID field.

### Changed
- Limit event upload size to 1MB.

### Fixed
- Local uses separate country and language codes to handle unsupported values better.

## [4.0.0](https://github.com/deltaDNA/ios-sdk/releases/tag/4.0.0) (2016-03-14)
Initial version 4.0 release.

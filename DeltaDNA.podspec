Pod::Spec.new do |spec|

  # Spec Metadata
  spec.name         = "DeltaDNA"
  spec.version      = "4.12.4"
  spec.summary      = "A gaming analytics platform."

  spec.homepage     = "https://deltadna.com"

  # Spec License 
  spec.license      = { :type => "APACHE", :file => "LICENSE" }

  # Author Metadata  
  spec.authors = { "Unity Technologies" => "engage-sdk-team@unity3d.com" }

  # Platform Specifics 
  spec.ios.deployment_target = "10.0"
  spec.tvos.deployment_target = "9.2"

  # Source Location 
  spec.source       = { :git => "https://github.com/deltaDNA/ios-sdk.git", :tag => spec.version }

  # Source Code 
  spec.source_files  = "DeltaDNA", "DeltaDNA/**/*.{h,m,swift}"
  spec.public_header_files = "DeltaDNA/**/*.h"
  spec.tvos.exclude_files = [
    "DeltaDNA/Framework/iOS/*.{h,m,swift}",
    "DeltaDNA/**/DDNAPinpointer.swift",
	"DeltaDNA/**/DDNANotifications*.{h,m,swift}"
  ]
  spec.ios.exclude_files = [
    "DeltaDNA/**/DDNAPinpointerTvOS.swift",
    "DeltaDNA/Framework/tvOS/*.{h,m,swift}"
  ]

  # Resources
  spec.resources = "DeltaDNA/Resources/**/*"

  # Project Linking

  # Project Settings
  spec.requires_arc = true

end

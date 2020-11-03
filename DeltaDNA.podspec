Pod::Spec.new do |spec|

  # Spec Metadata
  spec.name         = "DeltaDNA"
  spec.version      = "4.12.2"
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
    "DeltaDNA/**/DDNANotifications*.{h,m,swift}"
  ]
  spec.ios.exclude_files = [
    "DeltaDNA/Framework/tvOS/*.{h,m,swift}"
  ]


  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.resources = "DeltaDNA/Resources/**/*"

  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # spec.framework  = "SomeFramework"
  # spec.frameworks = "SomeFramework", "AnotherFramework"

  # spec.library   = "iconv"
  # spec.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  spec.requires_arc = true

  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # spec.dependency "JSONKit", "~> 1.4"

end

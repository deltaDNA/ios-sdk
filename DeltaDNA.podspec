Pod::Spec.new do |s|
    s.name = 'DeltaDNA'
    s.version = '4.12.1'
    s.license = { :type => 'APACHE', :file => 'LICENSE' }
    s.summary = 'A gaming analytics platform.'
    s.homepage = 'https://deltadna.com'
    s.authors = { 'Unity Technologies' => 'engage-sdk-team@unity3d.com' }
    s.source = { :git => 'https://github.com/deltaDNA/ios-sdk.git', :tag => s.version }
    s.ios.deployment_target = '10.0'
    s.tvos.deployment_target = '9.2'
    s.requires_arc = true

    s.public_header_files = 'DeltaDNA/**/*.h'
    s.source_files = 'DeltaDNA/**/*.{h,m}'
    s.tvos.exclude_files = [
      'DeltaDNA/Framework/iOS/*.{h,m}',
      'DeltaDNA/**/DDNANotifications*.{h,m}'
    ]
    s.ios.exclude_files = [
      'DeltaDNA/Framework/tvOS/*.{h,m}'
    ]
    s.header_mappings_dir = 'DeltaDNA'
    s.resources  = 'DeltaDNA/Resources/**/*'
end

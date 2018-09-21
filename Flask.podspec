
Pod::Spec.new do |s|

  s.name         = "Flask"
  s.version      = '1.1.18'
  s.summary      = "Flask Reactor"
  s.homepage     = "https://github.com/eonfluxor/flask"
  s.license      = "MIT"
  s.author             = { "Eonflux" => "eonflux@gmail.com" }
  s.social_media_url   = "http://twitter.com/eonfluxor"

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
   
  s.source       = { :git => "https://github.com/eonfluxor/flask.git", :tag => "v#{s.version}" }

  s.source_files = 'FlaskFramework/Sources/**/*.swift'
  s.swift_version = '4.1'
 
  s.dependency 'Delayed', '> 2.2.2'

  # s.resources = "Resources/*.png"
  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"
  # s.frameworks = "SomeFramework", "AnotherFramework"
  # s.libraries = "iconv", "xml2"
  # s.requires_arc = true
  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"

end

Pod::Spec.new do |s|
  s.name         = "GNLocationManager"
  s.version      = "0.0.7"
  s.summary      = "Manager for handling locations update easier"

  s.description  = <<-DESC
                   Manager for handling locations update easier.
                   DESC

  s.homepage     = "https://github.com/jakubknejzlik/GNLocationManager"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "Jakub Knejzlik" => "jakub.knejzlik@gmail.com" }

  #  When using multiple platforms
  s.ios.deployment_target = "7.1"
  #s.osx.deployment_target = "10.8"


  s.source       = { :git => "https://github.com/jakubknejzlik/GNLocationManager.git", :tag => s.version.to_s }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any h, m, mm, c & cpp files. For header
  #  files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #

  s.source_files  = "GNLocationManager", "GNLocationManager/**/*.{h,m}"

  s.framework  = "CoreLocation"

  s.requires_arc = true

  s.dependency "CWLSynthesizeSingleton"

end

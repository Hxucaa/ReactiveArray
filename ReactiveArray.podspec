#
# Be sure to run `pod lib lint ReactiveArray.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "ReactiveArray"
  s.version          = "0.3.0"
  s.summary          = "Reactive array for ReactiveCocoa."
  s.description      = <<-DESC
  An array class Implemented in Swift that can be observered using ReactiveCocoa's Signals. 
                      DESC

  s.homepage         = "https://github.com/Hxucaa/ReactiveArray"
  s.license          = 'MIT'
  s.author           = { "Lance Zhu" => "lancezhu77@gmail.com" }
  s.source           = { :git => "https://github.com/Hxucaa/ReactiveArray.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.ios.deployment_target = '8.0'
  
  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'ReactiveCocoa', '~> 4.1.0'
end

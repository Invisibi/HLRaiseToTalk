#
# Be sure to run `pod lib lint HLRaiseToTalk.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "HLRaiseToTalk"
  s.version          = "0.1.0"
  s.summary          = "Implement a Raise-To-Talk behavior using motion and proximity detectors"
  s.description      = Add a Raise-To-Talk gesture detection  to your app based on smart monitoring of the device's proximity and motion sensor. Supports notifications if a raise-to-talk gesture was detected.
  s.homepage         = "https://github.com/Invisibi/HLRaiseToTalk"
  s.license          = 'MIT'
  s.author           = { "Michael Kuck" => "michaelkuck@hooloop.com" }
  s.source           = { :git => "https://github.com/Invisibi/HLRaiseToTalk.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'HLRaiseToTalk' => ['Pod/Assets/*.png']
  }

  s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'Foundation', 'UIKit'
end

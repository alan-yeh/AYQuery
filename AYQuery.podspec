#
# Be sure to run `pod lib lint AYQuery.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AYQuery'
  s.version          = '2.0.3'
  s.summary          = 'Library for collection query.'

  s.homepage         = 'https://github.com/alan-yeh/AYQuery'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Alan Yeh' => 'alan@yerl.cn' }
  s.source           = { :git => 'https://github.com/alan-yeh/AYQuery.git', :tag => s.version.to_s }

  s.ios.deployment_target = '6.0'
  s.source_files = 'AYQuery/Classes/**/*'
  s.public_header_files = 'AYQuery/Classes/*.h'
  s.dependency 'AYRuntime'
end

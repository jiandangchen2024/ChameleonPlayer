Pod::Spec.new do |s|
  s.name     = 'ChameleonPlayer'
  s.version  = '0.0.1'
  s.author   = { 'Eyepetizer Inc.' => 'liuyan@kaiyanapp.com' }
  s.homepage = 'https://github.com/eyepetizers/ChameleonPlayer'
  s.summary  = 'ChameleonPlayer is a VR Video Player for iOS. Include 360 degress and VR Glasses Mode.'
  s.source   = { :git => 'https://github.com/eyepetizers/ChameleonPlayer.git', :tag => '0.0.1' }
  s.license  = 'MIT'
  
  s.platform = :ios
  s.source_files = 'Source/*.swift'
  s.requires_arc = true
  s.frameworks   = 'SpriteKit', 'AVFoundation', 'SceneKit'
end

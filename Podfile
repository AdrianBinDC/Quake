# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

target 'QuakeData' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  
  # Pods for CanvasQuake
  pod 'Alamofire', '~> 4.7'
  pod 'FSCalendar'
#  pod 'WARangeSlider'
  pod 'RangeSeekSlider'
  pod 'ReachabilitySwift'

  
  target 'QuakeDataTests' do
    inherit! :search_paths
    # Pods for testing
  end
  
  target 'QuakeDataUITests' do
    inherit! :search_paths
    # Pods for testing
  end
  
  post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
      config.build_settings.delete('CODE_SIGNING_ALLOWED')
      config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
  end

  
end

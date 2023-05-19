# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

target 'DatingApp' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  inhibit_all_warnings!
  use_frameworks!

  # Pods for DatingApp
  pod 'FacebookCore', '~> 0.9.0'
  pod 'FacebookLogin', '~> 0.9.0'
  pod 'FacebookShare', '~> 0.9.0'

  pod 'Firebase'
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Database'
  pod 'Firebase/Messaging'
  pod 'Firebase/Storage'
  pod 'Firebase/Firestore'
  pod 'Firebase/Analytics'

  pod 'Alamofire', '~> 5.2.1'
  pod 'Kingfisher', '~> 5.14.0'

  pod "Koloda", '~> 5.0.1'
  pod 'Eureka', '~> 5.2.1'
end
post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
               end
          end
   end
end

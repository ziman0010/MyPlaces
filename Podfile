# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'
post_install do |installer_representation|
    installer_representation.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
        end
    end
end
target 'testTableViewAppMyPlaces' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'RealmSwift'
  pod 'Cosmos', '~> 23.0'
end

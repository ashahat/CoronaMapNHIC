source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '12.0'
use_frameworks!

target 'Corona Map' do
    pod 'ExpandingMenu'#, '~> 0.4'
    pod 'IBMWatsonAssistantV2'#, '~> 3.2.0'
    pod 'Alamofire'#, '~> 5.0'
    pod 'AlamofireImage'
    pod 'MessageKit'
    pod 'NVActivityIndicatorView'
    pod 'SCLAlertView'
    post_install do |installer|
        installer.pods_project.targets.each do |target|
            if ['SwiftCloudant'].include? target.name
                target.build_configurations.each do |config|
                    config.build_settings['SWIFT_VERSION'] = '3.2'
                end
            end
        end
    end
end
pod 'OneSignal'#, '>= 2.11.2', '< 3.0'

target 'OneSignalNotificationServiceExtension' do
  pod 'OneSignal'#, '>= 2.11.2', '< 3.0'
end

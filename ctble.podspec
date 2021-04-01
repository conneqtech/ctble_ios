Pod::Spec.new do |s|
  s.name             = 'ctble'
  s.version          = '0.4.2'
  s.summary          = 'SDK to communicate with BLE enabled bluetooth trackers provided by Conneqtech'
  s.swift_version    = '5.0'

  s.description      = <<-DESC
  Enable communication between iOS apps and ble enabled trackers. This SDK is the main point of entry for all bluetooth comms.
                       DESC

  s.homepage         = 'https://bitbucket.org/nfnty_admin/ctble_ios'
  s.license          = { :type => 'proprietary', :file => 'LICENSE' }
  s.author           = { 'Conneqtech B.V.' => 'info@conneqtech.com' }
  s.source           = { :git => 'git@bitbucket.org:nfnty_admin/ctble_ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'Source/**/*.swift'

  s.dependency 'RxSwift', '~> 5.0'
end

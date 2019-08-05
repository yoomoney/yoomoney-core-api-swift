Pod::Spec.new do |spec|
  spec.name         = 'YandexMoneyCoreApi'
  spec.version      = '1.7.0'
  spec.homepage     = 'https://github.com/yandex-money/core-api-swift'
  spec.license = { 
    :type => "MIT", 
    :file => "LICENSE" 
  }
  spec.authors      = 'YandexMoney' 
  spec.summary      = 'Yandex Money Core API library'
  spec.source       = { 
    :git => 'https://github.com/yandex-money/core-api-swift.git',
    :tag => spec.version 
  }
  spec.module_name  = 'YandexMoneyCoreApi'

  spec.ios.deployment_target  = '8.0'
  spec.watchos.deployment_target = '2.0'

  spec.swift_version = '5.0'

  spec.source_files  = 'YandexMoneyCoreApi/**/*.swift'

  spec.dependency 'FunctionalSwift', '~> 1.1.0'
end

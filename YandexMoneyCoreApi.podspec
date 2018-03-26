Pod::Spec.new do |spec|
  spec.name         = 'YandexMoneyCoreApi'
  spec.version      = '0.0.6'
  spec.homepage     = 'https://bitbucket.browser.yandex-team.ru/projects/ML/repos/mobile-money-api-core-swift/browse'
  spec.license = { 
    :type => "MIT", 
    :file => "LICENSE" 
  }
  spec.authors      = 'YandexMoney' 
  spec.summary      = 'Yandex Money Core API library'
  spec.source       = { 
    :git => 'ssh://git@bitbucket.browser.yandex-team.ru/ml/mobile-money-api-core-swift.git', 
    :tag => spec.version 
  }
  spec.module_name  = 'YandexMoneyCoreApi'

  spec.ios.deployment_target  = '8.0'
  spec.swift_version = '4.0'

  spec.source_files  = 'YandexMoneyCoreApi/**/*.swift'

  spec.dependency "Alamofire", '~> 4.7.0'
  spec.dependency "Gloss", '~> 2.0.0'
  spec.dependency 'GMEllipticCurveCrypto', '~> 1.3'
  spec.dependency 'FunctionalSwift', '~> 1.0.5'
end

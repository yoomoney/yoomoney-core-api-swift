Pod::Spec.new do |spec|
  spec.name         = 'YandexMoneyCoreApi'
  spec.version      = '1.0.0'
  spec.homepage     = 'https://bitbucket.browser.yandex-team.ru/projects/ML/repos/mobile-money-ui-ios/browse'
  spec.license = { 
    :type => "MIT", 
    :file => "LICENSE" 
  }
  spec.authors      = 'YandexMoney' 
  spec.summary      = 'Swift Money Core API library'
  spec.source       = { 
    :git => 'ssh://git@bitbucket.browser.yandex-team.ru/ml/mobile-money-api-core-swift.git', 
    :tag => spec.version 
  }
  spec.module_name  = 'YandexMoneyCoreApi'

  spec.ios.deployment_target  = '9.0'

  spec.source_files  = 'YandexMoneyCoreApi/**/*.swift'

  spec.ios.framework  = 'UIKit'

  spec.dependency "Alamofire", "~> 4.5"
  spec.dependency "Gloss", "~> 1.2"
  spec.dependency 'GMEllipticCurveCrypto', :git => 'https://github.com/subtranix/GMEllipticCurveCrypto', :tag => '1.3.2'
end
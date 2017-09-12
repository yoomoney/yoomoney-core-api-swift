Pod::Spec.new do |spec|
  spec.name         = 'YandexMoneyCoreApi'
  spec.version      = '0.0.1'
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

  spec.ios.deployment_target  = '9.3'

  spec.source_files  = 'YandexMoneyUI/**/*.swift'

  spec.ios.framework  = 'UIKit'
end
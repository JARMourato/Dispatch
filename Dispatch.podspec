Pod::Spec.new do |s|
  s.name             = "Dispatch"
  s.version          = "1.0.0"
  s.summary          = "Just a tiny library to make using GCD easier and intuitive"
  s.homepage         = "https://github.com/Swiftification/Dispatch"
  s.license          = 'MIT'
  s.author           = { "João Mourato" => "joao.armourato@gmail.com", "Gabriel Peart" => "hello@swiftification.org" }
  s.source           = { :git => "https://github.com/Swiftification/Dispatch.git", :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'
  s.source_files = 'Sources/*.swift'
  s.module_name = 'DispatchFramework'
end

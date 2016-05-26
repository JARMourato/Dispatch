Pod::Spec.new do |s|
  s.name             = "Dispatch"
  s.version          = "0.9.3"
  s.summary          = "Just a tiny library to make using GCD easier and intuitive"
  s.homepage         = "https://github.com/DynamicThreads/Dispatch"
  s.license          = 'MIT'
  s.author           = { "João Mourato" => "joao.armourato@gmail.com", "Gabriel Peart" => "gabriel.peart@me.com" }
  s.source           = { :git => "https://github.com/DynamicThreads/Dispatch", :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'Sources/*.swift'
  s.module_name = 'DispatchFramework'
end

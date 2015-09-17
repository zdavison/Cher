Pod::Spec.new do |spec|
  spec.name         = 'Cher'
  spec.version      = '0.0.9'
  spec.platform     = :ios, '8.0'
  spec.license      = { :type => 'MIT' }
  spec.homepage     = 'https://github.com/zdavison/Cher'
  spec.authors      = { 'Zachary Davison' => 'zac.developer@gmail.com' }
  spec.summary      = 'Simple unified, gets-out-of-your-way interface for sharing on social networks'
  spec.source       = { :git => 'https://github.com/zdavison/Cher', :tag => '0.0.9' }
  spec.dependency   'ReactiveCocoa'
  spec.source_files = 'Cher/*.swift'
end

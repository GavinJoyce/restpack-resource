# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'restpack-resource/version'

Gem::Specification.new do |gem|
  gem.name          = "restpack-resource"
  gem.version       = RESTPack::Service::VERSION
  gem.authors       = ["Gavin Joyce"]
  gem.email         = ["gavinjoyce@gmail.com"]
  gem.description   = %q{REST resource paging, side-loading, filtering and sorting}
  gem.summary       = %q{...}
  gem.homepage      = "https://github.com/RESTpack/restpack-resource"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  
  gem.add_dependency 'active_support', '~> 3.0.0'
  gem.add_development_dependency 'rspec', '~> 2.12'
end

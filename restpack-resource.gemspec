# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'restpack-resource/version'

Gem::Specification.new do |gem|
  gem.name          = "restpack-resource"
  gem.version       = RestPack::Resource::VERSION
  gem.authors       = ["Gavin Joyce"]
  gem.email         = ["gavinjoyce@gmail.com"]
  gem.description   = %q{RESTful resource paging, side-loading, filtering and sorting}
  gem.summary       = %q{...}
  gem.homepage      = "https://github.com/RESTpack/restpack-resource"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  
  gem.add_dependency 'activesupport', '~> 3.2.11'
  gem.add_development_dependency 'rspec', '~> 2.12'
end

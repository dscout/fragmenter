# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fragmenter/version'

Gem::Specification.new do |gem|
  gem.name          = 'fragmenter'
  gem.version       = Fragmenter::VERSION
  gem.authors       = ['Parker Selbert']
  gem.email         = ['parker@sorentwo.com']
  gem.description   = %q{Fragmentize and rebuild data}
  gem.summary       = %q{Fragmentize and rebuild data}

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'redis', '~> 3.0.0'

  gem.add_development_dependency 'rspec', '~> 2.11.0'
end

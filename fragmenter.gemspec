# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fragmenter/version'

Gem::Specification.new do |gem|
  gem.name         = 'fragmenter'
  gem.version      = Fragmenter::VERSION
  gem.authors      = ['Parker Selbert']
  gem.email        = ['parker@sorentwo.com']
  gem.homepage     = 'https://github.com/dscout/fragmenter'
  gem.license      = 'MIT'
  gem.description  = 'Fragmentize and rebuild data'
  gem.summary      = <<-SUMMARY
    Multipart upload support backed by Redis. Fragmenter handles storing
    multiple parts of a larger binary and rebuilding it back into the original
    after all parts have been stored.
  SUMMARY

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(%r{^(spec)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'redis', '~> 3'
  gem.add_development_dependency 'rspec',     '~> 2.14.0'
  gem.add_development_dependency 'rack',      '~> 1.5.2'
  gem.add_development_dependency 'rack-test', '~> 0.6.2'
end

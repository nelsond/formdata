# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'formdata/version'

Gem::Specification.new do |spec|
  spec.name          = 'formdata'
  spec.version       = FormData::VERSION
  spec.authors       = ['Nelson Darkwah Oppong']
  spec.email         = ['n@darkwahoppong.com']

  spec.summary       = 'Ruby gem to generate data in the same format as "multipart/form-data".'
  spec.homepage      = 'http://github.com/nelsond/formdata'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 1.9.1'

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov', '~> 0.11'
  spec.add_development_dependency 'webmock', '~> 1.22'
  spec.add_development_dependency 'sinatra', '~> 1.4.6'
end

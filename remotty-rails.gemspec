# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'remotty/rails/version'

Gem::Specification.new do |spec|
  spec.name          = "remotty-rails"
  spec.version       = Remotty::Rails::VERSION
  spec.authors       = ["subicura"]
  spec.email         = ["subicura@subicura.com"]
  spec.summary       = 'rails base package by remotty'
  spec.description   = 'rails base package by remotty'
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'railties', '~> 4.0'
  spec.add_dependency 'active_model_serializers'
  spec.add_dependency 'rack-cors'
  spec.add_dependency 'paperclip'
  spec.add_dependency 'httparty'
  spec.add_runtime_dependency 'devise'
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end

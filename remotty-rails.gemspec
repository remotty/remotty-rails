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

  spec.add_dependency         'rack-cors',   '>= 0.2.9'
  spec.add_dependency         'active_model_serializers', '>= 0.8.1'

  spec.add_dependency         'devise',      '>= 3.2.4'
  spec.add_dependency         'omniauth-facebook', '>= 1.6.0'
  spec.add_dependency         'omniauth-twitter',  '>= 1.0.1'

  spec.add_dependency         'paperclip', '>= 4.1.1'
  spec.add_dependency         'rmagick',   '>= 2.13.2'
  spec.add_dependency         'fog',       '>= 1.22.0'
  spec.add_dependency         'httparty',  '>= 0.13.1'

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end

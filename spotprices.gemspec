# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'spotprices/version'

Gem::Specification.new do |spec|
  spec.name          = "spotprices"
  spec.version       = Spotprices::VERSION
  spec.authors       = ["Eric Herot"]
  spec.email         = ["eric.github@herot.com"]
  spec.summary       = %q{Gives a quick tabulated list of EC2 spot prices}
  spec.description   = spec.summary
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end

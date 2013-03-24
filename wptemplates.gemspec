# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wptemplates/version'

Gem::Specification.new do |spec|
  spec.name          = "wptemplates"
  spec.version       = Wptemplates::VERSION
  spec.authors       = ["Bernhard Häussner"]
  spec.email         = ["bxt@die-optimisten.net"]
  spec.description   = %q{Collect template informations from MediaWiki markup}
  spec.summary       = %q{Collect template informations from MediaWiki markup}
  spec.homepage      = "https://github.com/bxt/wptemplates"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  s.required_ruby_version = '>= 1.9' # regex named groups
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rdoc"
  spec.add_development_dependency "simplecov"
  #spec.add_development_dependency "wirble"
  
end

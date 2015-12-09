# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cksh_commander/version'

Gem::Specification.new do |spec|
  spec.name          = "cksh_commander"
  spec.version       = CKSHCommander::VERSION
  spec.authors       = ["Travis Loncar"]
  spec.email         = ["travis@openarc.net"]
  spec.license       = 'MIT'

  spec.summary       = %q{Process Slack slash commands with ease.}
  spec.description   = %q{Process Slack slash commands with ease.}
  spec.homepage      = "https://github.com/openarcllc/cksh_commander"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end

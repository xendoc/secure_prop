# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'secure_prop/version'

Gem::Specification.new do |spec|
  spec.name          = "secure_prop"
  spec.version       = SecureProp::VERSION
  spec.authors       = ["xendoc"]
  spec.email         = ["xendoc@users.noreply.github.com"]

  spec.summary       = %q{SecureProp property encryptor}
  spec.description   = %q{SecureProp adds encrypted property to your class.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'bcrypt-ruby'
  spec.add_dependency 'activemodel'
  spec.add_dependency 'activesupport'

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
end

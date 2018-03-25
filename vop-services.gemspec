# encoding: utf-8

Gem::Specification.new do |spec|
  spec.name          = "vop-services"
  spec.version       = "0.3.4"
  spec.authors       = ["Philipp T."]
  spec.email         = ["philipp@virtualop.org"]

  spec.summary       = %q{Service descriptors for the virtualop (see gem "vop").}
  spec.description   = %q{Metadata for how to install and operate services.}
  spec.licenses      = ['WTFPL']
  spec.homepage      = "http://www.virtualop.org"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 0"
  spec.add_development_dependency "rspec", "~> 0"
end

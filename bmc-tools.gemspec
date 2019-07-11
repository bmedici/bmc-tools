# coding: utf-8
Gem::Specification.new do |spec|
  # Project version
  spec.version                      = "0.2.1"

  # Project description
  spec.name                         = "bmc-tools"
  spec.authors                      = ["Bruno MEDICI"]
  spec.email                        = "opensource@bmconseil.com"
  spec.description                  = ""
  spec.summary                      = spec.description
  spec.homepage                     = "http://github.com/bmedici/bmc-tools"
  spec.licenses                     = ["MIT"]
  spec.date                         = Time.now.strftime("%Y-%m-%d")

  # List files and executables
  spec.files                        = `git ls-files -z`.split("\x0")
  #spec.executables                  = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.non_ruby_executables         = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths                = ["lib"]
  spec.required_ruby_version        = ">= 2.2"

  # Development dependencies
  spec.add_development_dependency   "bundler", "~> 1.6"
  spec.add_development_dependency   "rake"
  spec.add_development_dependency   "rspec"

  # Runtime dependencies
end

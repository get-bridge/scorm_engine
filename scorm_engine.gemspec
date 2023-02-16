lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "scorm_engine/version"

Gem::Specification.new do |spec|
  spec.name          = "scorm_engine"
  spec.version       = ScormEngine::VERSION
  spec.authors       = ["Philip Hallstrom", "Mel Green"]
  spec.email         = ["phallstrom@instructure.com", "mgreen@instructure.com"]

  spec.summary       = "Ruby Client for Rustici's SCORM Engine API"
  spec.description   = "Ruby Client for Rustici's SCORM Engine 2017.1 & 20.1 API"
  spec.homepage      = "https://github.com/get-bridge/scorm_engine"
  spec.license       = "MIT"
  spec.metadata      = { "documentation_uri" => "https://get-bridge.github.io/scorm_engine/" }

  spec.files         = Dir.glob("{lib,spec}/**/*") + %w[Rakefile .rspec]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.7"

  spec.add_dependency "faraday", ">=0.12", "<=2.0"
  spec.add_dependency "faraday_middleware", ">=0.12", "<=2.0"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "dotenv", "~> 2.4"
  spec.add_development_dependency "pry", "~> 0.1"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.0"
  spec.add_development_dependency "rubyzip", "~> 2.3"
  spec.add_development_dependency "vcr", "~> 6.0"
  spec.add_development_dependency "yard", "~> 0.9"
end

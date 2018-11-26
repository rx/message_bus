
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "voom/message_bus/version"

Gem::Specification.new do |spec|
  spec.name          = "voom-message_bus"
  spec.version       = Voom::MessageBus::VERSION
  spec.authors       = ["Russell Edens"]
  spec.email         = ["rx@voomify.com"]

  spec.summary       = %q{A lightweight micro-service message bus based on top of Sidekiq.}
  spec.homepage      = "https://github.com/rx/message_bus"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_dependency "dry-configurable"

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec_junit_formatter"
  spec.add_development_dependency "sidekiq"

end

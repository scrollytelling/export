
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "scrollytelling/export/version"

Gem::Specification.new do |spec|
  spec.name          = "scrollytelling-export"
  spec.version       = Scrollytelling::Export::VERSION
  spec.authors       = ["Joost Baaij"]
  spec.email         = ["joost@spacebabies.nl"]

  spec.summary       = %q{Export Scrollytelling.}
  spec.homepage      = "https://github.com/scrollytelling/export"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "pageflow", "~> 12.2.0"
  spec.add_runtime_dependency "rails", "~> 4.2.11"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end

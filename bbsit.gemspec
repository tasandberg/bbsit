
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "bbsit/version"

Gem::Specification.new do |spec|
  spec.name          = "bbsit"
  spec.version       = BBSit::VERSION
  spec.authors       = ["Tim Sandberg"]
  spec.email         = ["tasandberg@gmail.com"]

  spec.summary       = %q{Rerun relevant tests as you make code changes.}
  spec.description   = %q{Similar to the guard gem but works without the need to be added to your project's gem file. Neat!}
  spec.homepage      = "https://github.com/Timmehs/bbsit"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir['lib/**/*.rb']
  spec.bindir        = 'bin'
  spec.executables   = ['bbsit']
  spec.require_paths = ['lib']
  
  spec.add_runtime_dependency "filewatcher", "~> 1.1.1"
  spec.add_runtime_dependency "terminal-notifier"
  spec.add_runtime_dependency "childprocess"
  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rubocop", "~> 0.58.1"
  spec.add_development_dependency "pry"
end

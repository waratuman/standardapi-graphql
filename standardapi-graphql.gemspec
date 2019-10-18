lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "standard_api/graphql/version"

Gem::Specification.new do |spec|
  spec.name          = "standardapi-graphql"
  spec.version       = StandardAPI::Graphql::VERSION
  spec.authors       = ["James Bracy"]
  spec.email         = ["waratuman@gmail.com"]

  spec.summary       = %q{StandardAPI GraphQL extension.}
  spec.description   = %q{StandardAPI GraphQL extension.}
  spec.homepage      = "https://github.com/waratuman/standardapi-graphql"
  spec.license       = "MIT"

  spec.metadata["allowed_push_host"] = "http://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/waratuman/standardapi-graphql"
  spec.metadata["changelog_uri"] = "https://github.com/waratuman/standardapi-graphql/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "standardapi", "~> 6.0"
  spec.add_runtime_dependency "graphql", "~> 1.9"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "pg", "~> 1.1"
  spec.add_development_dependency "jbuilder", "~> 2.9"
  spec.add_development_dependency "factory_bot_rails", "~> 5.1"
  spec.add_development_dependency "faker", "~> 2.6"
  spec.add_development_dependency "byebug", "~> 11.0"
  spec.add_development_dependency "mocha", "~> 1.9"

end

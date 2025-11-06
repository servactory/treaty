# frozen_string_literal: true

require_relative "lib/treaty/version"

Gem::Specification.new do |spec|
  spec.name          = "treaty"
  spec.version       = Treaty::VERSION::STRING
  spec.platform      = Gem::Platform::RUBY

  spec.authors       = ["Anton Sokolov"]
  spec.email         = ["profox.rus@gmail.com"]

  spec.summary       = "A Ruby library for defining and managing REST API contracts with versioning support"
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/servactory/treaty"

  spec.license       = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["documentation_uri"] = "https://treaty.servactory.com"
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/issues"
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/master/CHANGELOG.md"

  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir["lib/**/*", "Rakefile", "README.md"]
  spec.require_paths = ["lib"]

  spec.required_ruby_version = Gem::Requirement.new(">= 3.2")

  spec.add_dependency "rails", ">= 7.1"
  spec.add_dependency "zeitwerk", ">= 2.6"

  spec.add_development_dependency "appraisal", ">= 2.5"
  spec.add_development_dependency "rake", ">= 13.2"
  spec.add_development_dependency "rspec", ">= 3.13"
  spec.add_development_dependency "rspec-rails", ">= 7.0"
  spec.add_development_dependency "servactory", ">= 2.16"
  spec.add_development_dependency "servactory-rubocop", ">= 0.9"
end

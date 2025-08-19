# frozen_string_literal: true

require_relative "lib/trmnl/liquid/version"

Gem::Specification.new do |spec|
  spec.name = "trmnl-liquid"
  spec.version = TRMNL::Liquid::VERSION
  spec.authors = ["TRMNL"]
  spec.email = ["engineering@usetrmnl.com"]
  spec.homepage = "https://github.com/usetrmnl/trmnl-liquid"

  spec.summary = "Liquid templating engine for TRMNL plugins"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/usetrmnl/trmnl-liquid/issues",
    "changelog_uri" => "https://github.com/usetrmnl/trmnl-liquid/tags",
    "homepage_uri" => "https://github.com/usetrmnl/trmnl-liquid",
    "label" => "TRMNL Liquid",
    "rubygems_mfa_required" => "true",
    "source_code_uri" => "https://github.com/usetrmnl/trmnl-liquid"
  }

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir["*.gemspec", "lib/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "actionview", "~> 8.0"
  spec.add_dependency "liquid", "~> 5.5"
  spec.add_dependency "redcarpet", "~> 3.6"
end

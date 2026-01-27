# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "trmnl-liquid"
  spec.version = "0.4.0"
  spec.authors = ["TRMNL"]
  spec.email = ["engineering@trmnl.com"]
  spec.homepage = "https://github.com/usetrmnl/trmnl-liquid"
  spec.summary = "Liquid templating engine for TRMNL plugins"
  spec.license = "MIT"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/usetrmnl/trmnl-liquid/issues",
    "changelog_uri" => "https://github.com/usetrmnl/trmnl-liquid/tags",
    "homepage_uri" => "https://github.com/usetrmnl/trmnl-liquid",
    "label" => "TRMNL Liquid",
    "rubygems_mfa_required" => "true",
    "source_code_uri" => "https://github.com/usetrmnl/trmnl-liquid"
  }

  spec.signing_key = Gem.default_key_path
  spec.cert_chain = [Gem.default_cert_path]

  spec.required_ruby_version = ">= 4.0"

  spec.add_dependency "liquid", "~> 5.11"
  spec.add_dependency "redcarpet", "~> 3.6"
  spec.add_dependency "rqrcode", "~> 3.2"
  spec.add_dependency "tzinfo", "~> 2.0"

  spec.extra_rdoc_files = Dir["README*", "LICENSE*"]
  spec.files = Dir["*.gemspec", "lib/**/*"]
end

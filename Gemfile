# frozen_string_literal: true

ruby file: ".ruby-version"

source "https://rubygems.org"

gemspec

gem "actionview", "~> 8.0"
gem "i18n", "~> 1.14"
gem "rails-i18n", "~> 8.0"
gem "trmnl-i18n", github: "usetrmnl/trmnl-i18n", branch: "main"

group :quality do
  gem "caliber", "~> 0.88"
  gem "git-lint", "~> 10.0"
  gem "reek", "~> 6.5", require: false
  gem "simplecov", "~> 0.22", require: false
end

group :development do
  gem "rake", "~> 13.3"
end

group :test do
  gem "refinements", "~> 14.2"
  gem "rspec", "~> 3.13"
end

group :tools do
  gem "amazing_print", "~> 2.0"
  gem "debug", "~> 1.11"
  gem "repl_type_completor", "~> 0.1"
end

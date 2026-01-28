# frozen_string_literal: true

require "liquid"
require "trmnl/liquid/file_system"
require "trmnl/liquid/filters"
require "trmnl/liquid/template_tag"

# optional
begin
  require "trmnl/i18n"
rescue LoadError
  nil
end

TRMNL::I18n.load_locales if defined?(TRMNL::I18n)

if Gem.loaded_specs["rails-i18n"]
  I18n.load_path += Pathname(Gem.loaded_specs["rails-i18n"].full_gem_path).join("rails/locale")
                                                                          .glob("*.yml")
end

module TRMNL
  module Liquid
    def self.build_environment(file_system: TRMNL::Liquid::FileSystem.new, **)
      ::Liquid::Environment.build(file_system:, **) do |environment|
        environment.register_filter TRMNL::Liquid::Filters
        environment.register_tag "template", TRMNL::Liquid::TemplateTag
        yield environment if block_given?
      end
    end
  end
end

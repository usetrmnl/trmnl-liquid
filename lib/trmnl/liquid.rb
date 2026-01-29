# frozen_string_literal: true

require "liquid"
require "trmnl/liquid/filters"
require "trmnl/liquid/memory_system"
require "trmnl/liquid/template_tag"

module TRMNL
  module Liquid
    def self.build_environment(file_system: TRMNL::Liquid::MemorySystem.new, **)
      ::Liquid::Environment.build(file_system:, **) do |environment|
        environment.register_filter TRMNL::Liquid::Filters
        environment.register_tag "template", TRMNL::Liquid::TemplateTag
        yield environment if block_given?
      end
    end

    def self.load key
      case key
        when :rails
          require "trmnl/liquid/rails_helpers"
          require "trmnl/i18n"

          TRMNL::I18n.load_locales
          path = Pathname Gem.loaded_specs["rails-i18n"].full_gem_path
          ::I18n.load_path += path.join("rails/locale").glob("*.yml")
        else fail KeyError, "Unable to load extension due to invalid key: #{key.inspect}."
      end
    end
  end
end

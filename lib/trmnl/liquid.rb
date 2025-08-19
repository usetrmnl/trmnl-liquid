# frozen_string_literal: true

require 'liquid'

require 'trmnl/liquid/filters'
require 'trmnl/liquid/file_system'
require 'trmnl/liquid/template_tag'
require 'trmnl/liquid/version'

begin
  require 'trmnl/i18n'
rescue LoadError
  nil
end

if defined?(::TRMNL::I18n)
  ::TRMNL::I18n.load_locales
end

if Gem.loaded_specs['rails-i18n']
  ::I18n.load_path += Pathname.new(Gem.loaded_specs['rails-i18n'].full_gem_path).join('rails', 'locale').glob('*.yml')
end

module TRMNL
  module Liquid
    def self.build_environment(*args)
      ::Liquid::Environment.build(*args) do |env|
        env.register_filter(TRMNL::Liquid::Filters)
        env.register_tag('template', TRMNL::Liquid::TemplateTag)
        env.file_system = TRMNL::Liquid::FileSystem.new
        yield(env) if block_given?
      end
    end
  end
end
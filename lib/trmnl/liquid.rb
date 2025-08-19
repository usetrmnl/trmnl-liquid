# frozen_string_literal: true

require 'trmnl/liquid/filters'
require 'trmnl/liquid/template'
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
  ::I18n.load_path += Dir[File.join(Gem.loaded_specs['rails-i18n'].full_gem_path, 'rails', 'locale', '*.yml')]
end

module TRMNL
  module Liquid
    # empty
  end
end

::Liquid::Template.register_filter(TRMNL::Liquid::Filters)
::Liquid::Template.register_tag('template', TRMNL::Liquid::Template::TemplateTag)

require 'liquid'

require_relative 'template/file_system'
require_relative 'template/template_tag'

module TRMNL
  module Liquid
    # A very thin wrapper around Liquid::Template with TRMNL-specific functionality.
    class Template < ::Liquid::Template
      def self.parse(*)
        template = super

        # set up a temporary in-memory file system for custom user templates, via the magic :file_system register
        # which will override the default file system
        template.registers[:file_system] = FileSystem.new

        template
      end
    end
  end
end
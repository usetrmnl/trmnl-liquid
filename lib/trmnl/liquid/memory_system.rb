# frozen_string_literal: true

module TRMNL
  module Liquid
    # An in-memory file system for storing custom templates defined with {% template [name] %} tags.
    class MemorySystem < ::Liquid::BlankFileSystem
      def initialize
        super
        @templates = {}
      end

      def register name, body
        templates[name] = body
      end

      def read_template_file name
        templates[name] || fail(::Liquid::FileSystemError, "Template not found: #{name}.")
      end

      private

      attr_reader :templates
    end
  end
end

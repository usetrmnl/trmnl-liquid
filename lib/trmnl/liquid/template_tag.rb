# frozen_string_literal: true

module TRMNL
  module Liquid
    # The {% template [name] %} tag block is used in conjunction with InlineTemplatesFileSystem to
    # allow users to define custom templates within the context of the current Liquid template.
    # Generally speaking, they will define their own templates in the "shared" markup content,
    # which is prepended to the individual screen templates before rendering.
    class TemplateTag < ::Liquid::Block
      NAME_PATTERN = %r(\A[a-zA-Z0-9_/]+\z)

      def initialize tag_name, markup, options
        super

        @name = markup.strip
        @body = +""
      end

      def parse tokens
        body.clear

        while (token = tokens.shift)
          break if token.strip == "{% endtemplate %}"

          body << token
        end
      end

      def render context
        unless NAME_PATTERN.match? name
          return "Liquid error: invalid template name #{name.inspect} - template names " \
                 "must contain only letters, numbers, underscores, and slashes"
        end

        context.registers[:file_system].register name, body.strip
        ""
      end

      private

      attr_reader :name, :body
    end
  end
end

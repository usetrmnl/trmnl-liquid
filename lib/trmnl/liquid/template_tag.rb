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
          return close token if end_tag? token

          body << token
        end

        raise_tag_never_closed block_name
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

      def end_tag?(token) = token[::Liquid::BlockBody::FullToken, 2] == block_delimiter

      def close(token) = parse_context.trim_whitespace = token.end_with?("-%}")
    end
  end
end

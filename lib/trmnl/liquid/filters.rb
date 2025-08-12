require 'action_view'
require 'redcarpet'
require 'i18n'

module TRMNL
  module Liquid
    module Filters
      def append_random(var)
        "#{var}#{SecureRandom.hex(2)}"
      end

      def days_ago(num)
        num.days.ago.to_date
      end

      def group_by(collection, key)
        collection.group_by { |obj| obj[key] }
      end

      def find_by(collection, key, value, fallback = nil)
        collection.find { |obj| obj[key] == value } || fallback
      end

      def markdown_to_html(markdown)
        markdown ||= ''
        renderer = Redcarpet::Render::HTML.new(_render_options = {})
        service = Redcarpet::Markdown.new(renderer, _extensions = {})
        service.render(markdown)
      end

      def number_with_delimiter(number, delimiter = ',', separator = ',')
        helpers.number_with_delimiter(number, delimiter: delimiter, separator: separator)
      end

      def number_to_currency(number, unit_or_locale = '$', delimiter = ',', separator = '.')
        cur_switcher = I18n.available_locales.include?(unit_or_locale.to_sym) ? :locale : :unit
        opts = { delimiter:, separator: }.merge(cur_switcher => unit_or_locale)
        helpers.number_to_currency(number, **opts)
      end

      def l_word(word, locale)
        I18n.t("custom_plugins.#{word}", locale: locale)
      end

      def l_date(date, format, locale = 'en')
        format = format.to_sym unless format.include?('%')
        I18n.l(date.to_datetime, :format => format, locale: locale)
      end

      def pluralize(singular, count)
        helpers.pluralize(count, singular)
      end

      def json(obj)
        JSON.generate(obj)
      end

      def sample(array) = array.sample

      private

      def helpers
        @helpers ||= begin
          mod = Module.new do
            include ::ActionView::Helpers::NumberHelper
            include ::ActionView::Helpers::TextHelper
          end
          Object.new.extend(mod)
        end
      end
    end
  end
end

# Liquid::Template.register_filter(TRMNL::Liquid::Filters)

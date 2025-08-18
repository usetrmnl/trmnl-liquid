require 'action_view'
require 'date'
require 'redcarpet'
require 'tzinfo'

begin
  require 'i18n'
rescue LoadError
  nil
end

module TRMNL
  module Liquid
    module Filters
      def append_random(var)
        "#{var}#{SecureRandom.hex(2)}"
      end

      def days_ago(num, tz = 'Etc/UTC')
        tzinfo = TZInfo::Timezone.get(tz)
        tzinfo.now.to_date - num.to_i
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
        cur_switcher = with_i18n(:unit) do |i18n|
          i18n.available_locales.include?(unit_or_locale.to_sym) ? :locale : :unit
        end
        opts = { delimiter:, separator: }.merge(cur_switcher => unit_or_locale)
        helpers.number_to_currency(number, **opts)
      end

      def l_word(word, locale)
        with_i18n("custom_plugins.#{word}") do |i18n|
          i18n.t("custom_plugins.#{word}", locale: locale)
        end
      end

      def l_date(date, format, locale = 'en')
        with_i18n(date.to_s) do |i18n|
          format = format.to_sym unless format.include?('%')
          i18n.l(to_datetime(date), format: format, locale: locale)
        end
      end

      def pluralize(singular, count)
        helpers.pluralize(count, singular)
      end

      def json(obj)
        JSON.generate(obj)
      end

      def sample(array) = array.sample

      private

      def with_i18n(fallback, &block)
        if defined?(::I18n)
          block.call(::I18n)
        else
          fallback
        end
      end

      def to_datetime(obj)
        case obj
        when DateTime
          obj
        when Date
          obj.to_datetime
        when Time
          DateTime.parse(obj.iso8601)
        else
          DateTime.parse(obj.to_s)
        end
      end

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

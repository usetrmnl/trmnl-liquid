# frozen_string_literal: true

require "date"
require "json"
require "redcarpet"
require "rqrcode"
require "securerandom"
require "tzinfo"

require_relative "fallback"

module TRMNL
  module Liquid
    module Filters
      def append_random var
        "#{var}#{SecureRandom.hex 2}"
      end

      def days_ago num, tz = "Etc/UTC"
        tzinfo = TZInfo::Timezone.get tz
        tzinfo.now.to_date - num.to_i
      end

      def group_by collection, key
        collection.group_by { |obj| obj[key] }
      end

      def find_by collection, key, value, fallback = nil
        collection.find { |obj| obj[key] == value } || fallback
      end

      def markdown_to_html markdown
        markdown ||= ""
        renderer = Redcarpet::Render::HTML.new _render_options = {}
        service = Redcarpet::Markdown.new renderer, _extensions = {}
        service.render markdown
      end

      def number_with_delimiter number, delimiter = ",", separator = "."
        if RailsHelpers.respond_to? :number_with_delimiter
          RailsHelpers.number_with_delimiter number, delimiter: delimiter, separator: separator
        else
          Fallback.number_with_delimiter number, delimiter, separator
        end
      end

      def number_to_currency number,
                             unit_or_locale = "$",
                             delimiter = ",",
                             separator = ".",
                             precision = 2
        if RailsHelpers.respond_to? :number_to_currency
          cur_switcher = with_i18n :unit do |i18n|
            i18n.available_locales.include?(unit_or_locale.to_sym) ? :locale : :unit
          end
          opts = {delimiter:, separator:, precision:}.merge cur_switcher => unit_or_locale
          RailsHelpers.number_to_currency(number, **opts)
        else
          Fallback.number_to_currency number, unit_or_locale, delimiter, separator, precision
        end
      end

      def l_word word, locale
        with_i18n "custom_plugins.#{word}" do |i18n|
          i18n.t "custom_plugins.#{word}", locale: locale
        end
      end

      def l_date date, format, locale = "en"
        with_i18n date.to_s do |i18n|
          format = format.to_sym unless format.include? "%"
          i18n.l to_datetime(date), format: format, locale: locale
        end
      end

      def map_to_i collection
        collection.map(&:to_i)
      end

      def pluralize singular, count, opts = {}
        plural = opts["plural"]
        locale = opts["locale"] || with_i18n(nil) { |i18n| i18n.locale } || "en"

        if RailsHelpers.respond_to? :pluralize
          RailsHelpers.pluralize count, singular, plural: plural, locale: locale
        else
          Fallback.pluralize count, singular, plural
        end
      end

      def json obj
        JSON.generate obj
      end

      def parse_json obj
        JSON.parse obj
      end

      def sample(array) = array.sample

      # source: https://github.com/jekyll/jekyll/blob/40ac06ed3e95325a07868dd2ac419e409af823b6/lib/jekyll/filters.rb#L209
      def where_exp input, variable, expression
        return input unless input.respond_to? :select

        input = input.values if input.is_a? Hash

        condition = parse_condition expression
        @context.stack do
          input.select do |object|
            @context[variable] = object
            condition.evaluate @context
          end
        end || []
      end

      def ordinalize date_str, strftime_exp
        date = Date.parse date_str

        ordinal_day = if date.day.respond_to? :ordinalize
                        date.day.ordinalize
                      else
                        Fallback.ordinalize date.day
                      end

        date.strftime strftime_exp.gsub("<<ordinal_day>>", ordinal_day)
      end

      def qr_code data, size = 11, level = ""
        level = "h" unless %w[l m q h].include? level.downcase

        qrcode = RQRCode::QRCode.new(data, level:)
        qrcode.as_svg(
          color: "000",
          fill: "fff",
          shape_rendering: "crispEdges",
          module_size: size,
          standalone: true,
          use_path: true,
          svg_attributes: {
            class: "qr-code"
          }
        )
      end

      private

      def with_i18n fallback
        if defined?(::I18n)
          yield ::I18n
        else
          fallback
        end
      end

      def to_datetime obj
        case obj
          when DateTime
            obj
          when Date
            obj.to_datetime
          when Time
            DateTime.parse(obj.iso8601)
          else
            DateTime.parse obj.to_s
        end
      end

      def parse_condition exp
        parser = ::Liquid::Parser.new exp
        condition = parse_binary_comparison parser

        parser.consume :end_of_string
        condition
      end

      def parse_binary_comparison parser
        condition = parse_comparison parser
        first_condition = condition
        while (binary_operator = parser.id?("and") || parser.id?("or"))
          child_condition = parse_comparison parser
          condition.send binary_operator, child_condition
          condition = child_condition
        end
        first_condition
      end

      def parse_comparison parser
        left_operand = ::Liquid::Expression.parse parser.expression
        operator     = parser.consume? :comparison

        # No comparison-operator detected. Initialize a Liquid::Condition using only left operand
        return ::Liquid::Condition.new left_operand unless operator

        # Parse what remained after extracting the left operand and the `:comparison` operator
        # and initialize a Liquid::Condition object using the operands and the comparison-operator
        ::Liquid::Condition.new left_operand, operator, ::Liquid::Expression.parse(parser.expression)
      end
    end
  end
end

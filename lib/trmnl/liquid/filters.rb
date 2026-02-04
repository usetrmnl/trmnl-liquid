# frozen_string_literal: true

require "json"
require "redcarpet"
require "rqrcode"
require "securerandom"
require "tzinfo"

require_relative "fallback"

module TRMNL
  module Liquid
    # rubocop:todo Metrics/ModuleLength
    module Filters
      def append_random(value) = "#{value}#{SecureRandom.hex 2}"

      def days_ago value, timezone = "Etc/UTC"
        TZInfo::Timezone.get(timezone).now.to_date - value.to_i
      end

      def group_by(collection, key) = collection.group_by { it[key] }

      # :reek:ControlParameter
      # rubocop:todo Metrics/ParameterLists
      def find_by collection, key, value, fallback = nil
        collection.find { |obj| obj[key] == value } || fallback
      end
      # rubocop:enable Metrics/ParameterLists

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

      # :reek:TooManyStatements
      # rubocop:todo Metrics/ParameterLists
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
      # rubocop:enable Metrics/ParameterLists

      def l_word word, locale
        with_i18n("custom_plugins.#{word}") { |i18n| i18n.t "custom_plugins.#{word}", locale: }
      end

      # :reek:FeatureEnvy
      def l_date value, format, locale = "en"
        with_i18n value.to_s do |i18n|
          format = format.to_sym unless format.include? "%"
          i18n.l to_time(value), format:, locale:
        end
      end

      def map_to_i(collection) = collection.map(&:to_i)

      # :reek:FeatureEnvy
      # rubocop:todo Style/OptionHash
      def pluralize singular, count, options = {}
        plural = options["plural"]
        locale = options["locale"] || with_i18n(nil, &:locale) || "en"

        if RailsHelpers.respond_to? :pluralize
          RailsHelpers.pluralize count, singular, plural: plural, locale: locale
        else
          Fallback.pluralize count, singular, plural
        end
      end
      # rubocop:enable Style/OptionHash

      def json(value) = JSON.generate value

      def parse_json(value) = JSON.parse value

      def sample(array) = array.sample

      # :reek:TooManyStatements
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

      # :reek:FeatureEnvy
      def ordinalize value, strftime_format
        time = to_time value
        day = time.day
        ordinal_day = day.respond_to?(:ordinalize) ? day.ordinalize : Fallback.ordinalize(day)

        time.strftime strftime_format.gsub("<<ordinal_day>>", ordinal_day)
      end

      # rubocop:todo Metrics/MethodLength
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
      # rubocop:enable Metrics/MethodLength

      private

      def with_i18n fallback
        if defined?(::I18n)
          yield ::I18n
        else
          fallback
        end
      end

      def to_time value
        case value
          when "now", "today" then Time.now
          when Integer then Time.at(value)
          else Time.parse value
        end
      end

      def parse_condition expression
        parser = ::Liquid::Parser.new expression
        condition = parse_binary_comparison parser

        parser.consume :end_of_string
        condition
      end

      # :reek:TooManyStatements
      # :reek:DuplicateMethodCall
      def parse_binary_comparison parser
        condition = parse_comparison parser
        first_condition = condition

        while (binary_operator = parser.id?("and") || parser.id?("or"))
          child_condition = parse_comparison parser
          condition.public_send binary_operator, child_condition
          condition = child_condition
        end

        first_condition
      end

      # :reek:DuplicateMethodCall
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
    # rubocop:enable Metrics/ModuleLength
  end
end

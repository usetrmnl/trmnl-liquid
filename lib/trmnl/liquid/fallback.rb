# frozen_string_literal: true

module TRMNL
  module Liquid
    # library-native formatting functions that don't rely on ActionView helpers
    module Fallback
      module_function

      def number_with_delimiter number, delimiter, separator
        str = number.to_s

        # return early if it's not a simple numeric-like string
        return str unless str.match?(/\A-?\d+(\.\d+)?\z/)

        integer, fractional = str.split "."
        negative = integer.start_with? "-"
        integer = integer[1..] if negative

        integer_with_delimiters = integer.reverse.scan(/\d{1,3}/).join(delimiter).reverse
        integer_with_delimiters = "-#{integer_with_delimiters}" if negative

        if fractional
          integer_with_delimiters + separator + fractional
        else
          integer_with_delimiters
        end
      end

      def number_to_currency number, unit, delimiter, separator, precision
        result = number_with_delimiter number, delimiter, separator
        dollars, cents = result.split separator

        if precision <= 0
          "#{unit}#{dollars}"
        else
          cents = cents.to_s[0..(precision - 1)].ljust precision, "0"
          "#{unit}#{dollars}#{separator}#{cents}"
        end
      end

      def ordinalize number
        suffix = if (11..13).include? number % 100
                   "th"
                 else
                   case number % 10
                     when 1 then "st"
                     when 2 then "nd"
                     when 3 then "rd"
                     else "th"
                   end
                 end

        "#{number}#{suffix}"
      end

      def pluralize count, singular, plural
        plural ||= "#{singular}s"
        count == 1 ? "1 #{singular}" : "#{count} #{plural}"
      end
    end
  end
end

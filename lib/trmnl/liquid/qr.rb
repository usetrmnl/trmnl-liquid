require 'rqrcode'

module TRMNL
  module Liquid
    module QR
      TYPES = %i[text contact wifi sms event].freeze
      LEVELS = %i[l m q h].freeze
      DEFAULT_LEVEL = :m
      DEFAULT_SIZE = 2

      def qr(data, size = DEFAULT_SIZE, level = DEFAULT_LEVEL)
        return '' if data.nil? || data.to_s.strip.empty?

        level = level.to_sym if level.is_a?(String)
        level = DEFAULT_LEVEL unless LEVELS.include?(level)

        qrcode = RQRCode::QRCode.new(data, size: size, level: level)
        qrcode.as_svg(
          color: '000',
          fill: 'fff',
          shape_rendering: 'crispEdges',
          module_size: 11,
          standalone: true,
          use_path: true,
          svg_attributes: {
            class: 'qr-code'
          }
        )
      end

      # Future consideration ###
      # Add built-in support for generation different types of QR code (see `TYPES` above)
      # instead of having the user specify the headers/structure of the data themselves.
      # – Paul
    end
  end
end

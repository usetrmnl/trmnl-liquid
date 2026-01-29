# frozen_string_literal: true

require "action_view"

module TRMNL
  module Liquid
    # Defines Rails helpers for use in filters.
    module RailsHelpers
      extend ActionView::Helpers::TextHelper
      extend ActionView::Helpers::NumberHelper
    end
  end
end

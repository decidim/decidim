# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # This concern contains defines methods used in other parts of the
  # application related with redesign and disables redesign features
  #
  module DisabledRedesignLayout
    extend ActiveSupport::Concern

    included do
      helper_method :redesigned_layout, :redesign_enabled?

      def redesign_enabled?
        false
      end

      def redesigned_layout(layout_value)
        layout_value
      end
    end
  end
end

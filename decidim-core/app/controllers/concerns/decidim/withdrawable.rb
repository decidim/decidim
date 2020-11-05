# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A controller concern to enable withawing the controller resources. Only
  # affects the UI, so the actual logic to withdraw the resource will still need
  # to be implemented.
  module Withdrawable
    extend ActiveSupport::Concern

    included do
      helper_method :withdrawable_controller?

      def withdrawable_controller?
        true
      end
    end
  end
end

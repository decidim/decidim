# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Budgets
    # Shared behaviour for controllers that need the current order to be present.
    module NeedsCurrentOrder
      extend ActiveSupport::Concern

      included do
        helper_method :current_order

        # The current order created by the user.
        #
        # Returns an Order.
        def current_order
          @current_order ||= Order.includes(:projects).find_by(user: current_user, component: current_component)
        end

        def current_order=(order)
          @current_order = order
        end
      end
    end
  end
end

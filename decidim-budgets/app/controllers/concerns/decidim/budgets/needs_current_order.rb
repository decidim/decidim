# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Budgets
    # Shared behaviour for controllers that need the current order to be present.
    module NeedsOrganization
      extend ActiveSupport::Concern

      included do
        helper_method :current_order

        # The current order created by the user.
        #
        # Returns an Order.
        def current_order
          @current_order ||= Order.find_or_create_by(user: current_user, feature: current_feature)
        end
      end
    end
  end
end

# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Budgets
    # Shared behaviour for controllers that need the current order to be present.
    module NeedsCurrentOrder
      extend ActiveSupport::Concern

      included do
        helper_method :current_order, :can_have_order?, :voted_for?

        # The current order created by the user.
        #
        # Returns an Order.
        def current_order
          @current_order ||= Order.includes(:projects).find_or_initialize_by(user: current_user, budget:)
        end

        def current_order=(order)
          @current_order = order
        end

        def persisted_current_order
          current_order if current_order&.persisted?
        end

        def can_have_order?
          current_user.present? &&
            voting_open? &&
            current_participatory_space.can_participate?(current_user) &&
            allowed_to?(:create, :order, budget:, workflow: current_workflow)
        end

        # Return true if the user has voted the project
        def voted_for?(project)
          current_order && current_order.projects.include?(project)
        end
      end
    end
  end
end

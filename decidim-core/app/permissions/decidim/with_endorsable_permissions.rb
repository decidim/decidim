# frozen_string_literal: true

module Decidim
  module WithEndorsablePermissions
    extend ActiveSupport::Concern

    included do
      # Checks if a resource can be endorsed.
      # Performs a toggle_allow with the authorization status.
      # The status is computed for the current user, the :endorse action and the given resource.
      def can_endorse?(resource)
        is_allowed = resource &&
                     authorized?(:endorse, resource: resource) &&
                     current_settings&.endorsements_enabled? &&
                     !current_settings&.endorsements_blocked?

        toggle_allow(is_allowed)
      end

      # Checks if a resource can be unendorsed.
      # Thus, a user that can endorse will also be able to unendorse.
      def can_unendorse?(resource)
        can_endorse?(resource)
      end
    end
  end
end

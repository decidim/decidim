# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module OnboardingActionMethods
    extend ActiveSupport::Concern

    included do
      helper_method :pending_onboarding_action?

      # Returns true if there's a pending onboarding action for the user.
      # The check if skipped for admins, users that are not verifiable of
      # organizations that have no available authorizations.
      def pending_onboarding_action?(user)
        return false if user.blank?
        return false if user.admin?
        return false unless user.verifiable?
        return false if current_organization.available_authorizations.empty?

        OnboardingManager.new(user).pending_action?
      end
    end
  end
end

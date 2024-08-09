# frozen_string_literal: true

module Decidim
  # A helper to display onboarding action message
  module OnboardingActionHelper
    def display_onboarding_action_message(user)
      return if user.blank?
      return unless pending_onboarding_action?(user)

      cell("decidim/onboarding_action_message", user)
    end
  end
end

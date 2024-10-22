# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module OnboardingActionMethods
    extend ActiveSupport::Concern

    included do
      helper_method :pending_onboarding_action?

      # Returns true if there is a pending onboarding action for the user.
      # The check if skipped for admins, users that are not verifiable of
      # organizations that have no available authorizations.
      def pending_onboarding_action?(user)
        return false if user.blank?
        return false if user.admin?
        return false unless user.verifiable?
        return false if current_organization.available_authorizations.empty?

        OnboardingManager.new(user).pending_action?
      end

      def store_onboarding_cookie_data!(user)
        data_key = OnboardingManager::DATA_KEY

        if cookies[data_key]
          onboarding_data = JSON.parse(cookies[data_key]).transform_keys(&:underscore)

          user.extended_data = user.extended_data.merge(data_key => onboarding_data)
          user.save!

          cookies.delete(data_key)
        end
      rescue JSON::ParserError
        cookies.delete(data_key)
      end

      def clear_onboarding_data!(user)
        user.extended_data = user.extended_data.except(OnboardingManager::DATA_KEY)
        user.save!
      end
    end
  end
end

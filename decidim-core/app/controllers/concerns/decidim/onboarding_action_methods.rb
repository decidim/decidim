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
        data = onboarding_cookie_data
        return if data.nil?

        if data.present?
          user.extended_data = user.extended_data.merge(data)
          user.save!
        end
        cookies.delete(OnboardingManager::DATA_KEY)
      end

      def onboarding_cookie_data
        data_key = OnboardingManager::DATA_KEY
        return unless cookies[data_key]

        { data_key => JSON.parse(cookies[data_key]).transform_keys(&:underscore) }
      rescue JSON::ParserError
        {}
      end

      def clear_onboarding_data!(user)
        return if user.ephemeral?

        user.extended_data = user.extended_data.except(OnboardingManager::DATA_KEY)
        user.save!
      end
    end
  end
end

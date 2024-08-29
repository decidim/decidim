# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module DeviseAuthenticationMethods
    extend ActiveSupport::Concern
    include Decidim::UserBlockedChecker
    include Decidim::OnboardingActionMethods

    included do
      def after_sign_in_path_for(user)
        if user.present? && user.blocked?
          check_user_block_status(user)
        elsif user.needs_password_update?
          decidim.change_password_path
        elsif pending_onboarding_action?(user)
          decidim_verifications.onboarding_pending_authorizations_path
        else
          super
        end
      end

      # Calling the `stored_location_for` method removes the key, so in order
      # to check if there is any pending redirect after login I need to call
      # this method and use the value to set a pending redirect. This is the
      # only way to do this without checking the session directly.
      def pending_redirect?(user)
        store_location_for(user, stored_location_for(user))
      end
    end
  end
end

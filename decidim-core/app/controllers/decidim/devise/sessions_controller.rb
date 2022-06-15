# frozen_string_literal: true

module Decidim
  module Devise
    # Custom Devise SessionsController to avoid namespace problems.
    class SessionsController < ::Devise::SessionsController
      include Decidim::DeviseControllers

      # rubocop: disable Rails/LexicallyScopedActionFilter
      before_action :check_sign_in_enabled, only: :create
      # rubocop: enable Rails/LexicallyScopedActionFilter

      def destroy
        current_user.invalidate_all_sessions!
        if params[:translation_suffix].present?
          super { set_flash_message! :notice, params[:translation_suffix], { scope: "decidim.devise.sessions" } }
        else
          super
        end
      end

      def after_sign_in_path_for(user)
        if user.present? && user.blocked?
          check_user_block_status(user)
        elsif needs_to_update_password?(user)
          user.update(password_updated_at: nil)
          change_password_path
        elsif first_login_and_not_authorized?(user) && !user.admin? && !pending_redirect?(user)
          decidim_verifications.first_login_authorizations_path
        else
          super
        end
      end

      # Calling the `stored_location_for` method removes the key, so in order
      # to check if there's any pending redirect after login I need to call
      # this method and use the value to set a pending redirect. This is the
      # only way to do this without checking the session directly.
      def pending_redirect?(user)
        store_location_for(user, stored_location_for(user))
      end

      def first_login_and_not_authorized?(user)
        user.is_a?(User) && user.sign_in_count == 1 && current_organization.available_authorizations.any? && user.verifiable?
      end

      def after_sign_out_path_for(user)
        request.referer || super
      end

      private

      def check_sign_in_enabled
        redirect_to new_user_session_path unless current_organization.sign_in_enabled?
      end

      def needs_to_update_password?(user)
        return false unless user.admin?
        return false unless Decidim.config.admin_password_strong_enable
        return true if user.password_updated_at.blank?

        user.password_updated_at < Decidim.config.admin_password_days_expiration.days.ago
      end
    end
  end
end

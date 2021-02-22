# frozen_string_literal: true

module Decidim
  module Devise
    # Custom Devise SessionsController to avoid namespace problems.
    class SessionsController < ::Devise::SessionsController
      include Decidim::DeviseControllers

      # rubocop: disable Rails/LexicallyScopedActionFilter
      before_action :check_sign_in_enabled, only: :create
      # rubocop: enable Rails/LexicallyScopedActionFilter
      prepend_before_action :skip_timeout, only: :seconds_until_timeout

      def skip_timeout
        request.env["devise.skip_trackable"] = true
        request.env["devise.skip_timeoutable"] = true
      end

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

      def seconds_until_timeout
        seconds_remaining = current_user ? ::Devise.timeout_in - (Time.current - Time.zone.at(user_session["last_request_at"])) : 0
        respond_to do |format|
          format.json { render json: { seconds_remaining: seconds_remaining }, status: :ok }
        end
      end

      def heartbeat
        respond_to do |format|
          format.js
        end
      end

      private

      def check_sign_in_enabled
        redirect_to new_user_session_path unless current_organization.sign_in_enabled?
      end
    end
  end
end

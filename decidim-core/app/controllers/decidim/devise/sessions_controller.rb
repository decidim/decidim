# frozen_string_literal: true

module Decidim
  module Devise
    # Custom Devise SessionsController to avoid namespace problems.
    class SessionsController < ::Devise::SessionsController
      include Decidim::DeviseControllers
      include Decidim::DeviseAuthenticationMethods
      helper Decidim::ShortLinkHelper
      helper Decidim::ResourceHelper

      before_action :check_sign_in_enabled, only: :create

      def create
        super do |user|
          if user.admin?
            # Check that the admin password passes the validation and clear the
            # `password_updated_at` field when the password is weak to force a
            # password update on the user.
            #
            # Handles a case when the user registers through the registration
            # form and they are promoted to an admin after that. In this case,
            # the newly promoted admin user would otherwise have to change their
            # password straight away even if they originally registered with a
            # strong password.
            validator = PasswordValidator.new({ attributes: :password })
            user.update!(password_updated_at: nil) unless validator.validate_each(user, :password, sign_in_params[:password])
          end

          store_onboarding_cookie_data!(user)
        end
      end

      def destroy
        current_user.invalidate_all_sessions!
        if params[:translation_suffix].present?
          super { set_flash_message! :notice, params[:translation_suffix], { scope: "decidim.devise.sessions" } }
        else
          super
        end
      end

      def after_sign_out_path_for(user)
        request.referer || super
      end

      private

      def check_sign_in_enabled
        redirect_to new_user_session_path unless current_organization.sign_in_enabled?
      end
    end
  end
end

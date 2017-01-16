# frozen_string_literal: true
module Decidim
  module Devise
    # This controller customizes the behaviour of Devise::Omniauthable.
    class OmniauthCallbacksController < ::Devise::OmniauthCallbacksController
      include Decidim::NeedsOrganization
      include Decidim::LocaleSwitcher
      helper Decidim::TranslationsHelper

      def facebook
        @user = User.find_or_create_from_oauth(env["omniauth.auth"], current_organization)

        if @user.persisted?
          if @user.active_for_authentication?
            sign_in_and_redirect @user, event: :authentication
            set_flash_message :notice, :success, kind: "Facebook"
          else
            expire_data_after_sign_in!
            redirect_to root_path
            flash[:notice] = t("devise.registrations.signed_up_but_unconfirmed")
          end
        else
          redirect_to root_path
          set_flash_message :alert, :failure, kind: "Facebook", reason: t(".email_already_exists")
        end
      end

      def after_sign_in_path_for(user)
        if !pending_redirect?(user) && first_login_and_not_authorized?(user)
          authorizations_path
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
        user.is_a?(User) && user.sign_in_count == 1 && Decidim.authorization_handlers.any?
      end
    end
  end
end

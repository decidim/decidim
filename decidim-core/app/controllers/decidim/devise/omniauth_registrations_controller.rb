# frozen_string_literal: true

module Decidim
  module Devise
    # This controller customizes the behaviour of Devise::Omniauthable.
    class OmniauthRegistrationsController < ::Devise::OmniauthCallbacksController
      include FormFactory
      include Decidim::DeviseControllers

      def new
        @form = form(OmniauthRegistrationForm).from_params(params[:user])
      end

      def create
        form_params = user_params_from_oauth_hash || params[:user]
        @form = form(OmniauthRegistrationForm).from_params(form_params)
        @form.email ||= verified_email

        CreateOmniauthRegistration.call(@form, verified_email) do
          on(:ok) do |user|
            if user.active_for_authentication?
              sign_in_and_redirect user, event: :authentication
              set_flash_message :notice, :success, kind: @form.provider.capitalize
            else
              expire_data_after_sign_in!
              redirect_to root_path
              flash[:notice] = t("devise.registrations.signed_up_but_unconfirmed")
            end
          end

          on(:invalid) do
            set_flash_message :notice, :success, kind: @form.provider.capitalize
            render :new
          end

          on(:error) do |user|
            if user.errors[:email]
              set_flash_message :alert, :failure, kind: @form.provider.capitalize, reason: t("decidim.devise.omniauth_registrations.create.email_already_exists")
            end

            render :new
          end
        end
      end

      def action_missing(action_name)
        return send(:create) if devise_mapping.omniauthable? && User.omniauth_providers.include?(action_name.to_sym)
        raise AbstractController::ActionNotFound, "The action '#{action_name}' could not be found for Decidim::Devise::OmniauthCallbacksController"
      end

      private

      def oauth_data
        return {} unless request.env["omniauth.auth"]
        @oauth_data ||= request.env["omniauth.auth"].slice(:provider, :uid, :info)
      end

      # Private: Create form params from omniauth hash
      # Since we are using trusted omniauth data we are generating a valid signature.
      def user_params_from_oauth_hash
        return nil unless request.env["omniauth.auth"]
        {
          provider: oauth_data[:provider],
          uid: oauth_data[:uid],
          name: oauth_data[:info][:name],
          oauth_signature: OmniauthRegistrationForm.create_signature(oauth_data[:provider], oauth_data[:uid])
        }
      end

      def verified_email
        @verified_email ||= oauth_data.dig(:info, :email)
      end
    end
  end
end

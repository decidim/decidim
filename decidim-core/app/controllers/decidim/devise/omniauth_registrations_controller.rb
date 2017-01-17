# frozen_string_literal: true
module Decidim
  module Devise
    # This controller customizes the behaviour of Devise::Omniauthable.
    class OmniauthRegistrationsController < ::Devise::OmniauthCallbacksController
      include FormFactory

      include Decidim::NeedsOrganization
      include Decidim::LocaleSwitcher
      helper Decidim::TranslationsHelper

      layout "layouts/decidim/application"

      def new
        @form = form(OmniauthRegistrationForm).from_params(params[:user])
      end

      def create
        params[:user] = user_params_from_oauth_hash if request.env["omniauth.auth"].present?
        @form = form(OmniauthRegistrationForm).from_params(params[:user])

        CreateOmniauthRegistration.call(@form) do
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

          on(:error) do
            redirect_to decidim.new_user_session_path
            set_flash_message :alert, :failure, kind: @form.provider, reason: t("decidim.devise.omniauth_registrations.create.email_already_exists")
          end
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

      def action_missing(action_name)
        if devise_mapping.omniauthable? && User.omniauth_providers.include?(action_name.to_sym)
          send :create
        else
          raise AbstractController::ActionNotFound, "The action '#{action_name}' could not be found for Decidim::Devise::OmniauthCallbacksController"
        end
      end

      private

      def user_params_from_oauth_hash
        oauth_data = request.env["omniauth.auth"].slice(:provider, :uid, :info)
        {
          provider: oauth_data[:provider],
          uid: oauth_data[:uid],
          email: oauth_data[:info][:email],
          email_verified: oauth_data[:info][:verified],
          name: oauth_data[:info][:name]
        }
      end
    end
  end
end

# raise InvalidOauthSignature unless verify_oauth_signature

# def verify_oauth_signature
#   user_params = params[:user]
#   return true if user_params.nil? || user_params[:oauth_signature].blank?
#   OmniauthFinishSignupForm.verify_signature(user_params[:provider], user_params[:uid], user_params[:oauth_signature])
# end

# class InvalidOauthSignature < StandardError; end;

# @user = User.find_or_create_from_oauth(request.env["omniauth.auth"], current_organization)

# if @user.persisted?
#   if @user.active_for_authentication?
#     sign_in_and_redirect @user, event: :authentication
#     set_flash_message :notice, :success, kind: provider.capitalize
#   else
#     expire_data_after_sign_in!
#     redirect_to root_path
#     flash[:notice] = t("devise.registrations.signed_up_but_unconfirmed")
#   end
# else
#   if @user.email.blank?
#     @form = form(OmniauthFinishSignupForm).instance({
#       name: @user.name,
#       password: @user.password,
#       password_confirmation: @user.password_confirmation,
#       provider: request.env["omniauth.auth"][:provider],
#       uid: request.env["omniauth.auth"][:uid]
#     })
#     set_flash_message :notice, :success, kind: provider.capitalize
#     render :finish_signup
#   else
#     redirect_to root_path
#     set_flash_message :alert, :failure, kind: provider.capitalize, reason: t(".email_already_exists")
#   end
# end

# @form = form(OmniauthFinishSignupForm).from_params(params[:user])
# @user = User.new(params[:user])
# @user.save

# if @user.persisted?
#   if @user.active_for_authentication?
#     sign_in_and_redirect @user, event: :authentication
#     set_flash_message :notice, :success, kind: @form.provider.capitalize
#   else
#     flash[:notice] = t("devise.registrations.signed_up_but_unconfirmed")
#     expire_data_after_sign_in!
#     respond_with resource, location: after_inactive_sign_up_path_for(resource)
#   end
# else
#   respond_with resource
# end

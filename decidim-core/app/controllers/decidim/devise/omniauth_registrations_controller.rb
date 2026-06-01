# frozen_string_literal: true

module Decidim
  module Devise
    # This controller customizes the behaviour of Devise::Omniauthable.
    class OmniauthRegistrationsController < ::Devise::OmniauthCallbacksController
      include FormFactory
      include Decidim::DeviseControllers
      include Decidim::DeviseAuthenticationMethods
      include NeedsTosAccepted

      def new
        @form = form(OmniauthRegistrationForm).from_params(params[:user])
      end

      def create
        return handle_missing_oauth_data! if pending_oauth_data.blank?

        form_params = form_params_from_pending_oauth

        @form = form(OmniauthRegistrationForm).from_params(form_params)
        CreateOmniauthRegistration.call(@form, verified_email) do
          on(:ok) do |user|
            clear_pending_oauth_data!

            if user.active_for_authentication?
              sign_in_and_redirect user, event: :authentication
              set_flash_message :notice, :success, kind: @form.provider.capitalize
            else
              expire_data_after_sign_in!
              user.resend_confirmation_instructions unless user.confirmed?
              redirect_to decidim.root_path
              flash[:notice] = t("devise.registrations.signed_up_but_unconfirmed")
            end
          end

          on(:invalid) do
            set_flash_message :notice, :success, kind: @form.provider.capitalize
            render :new, status: :unprocessable_content
          end

          on(:add_tos_errors) do
            set_flash_message :alert, :add_tos_errors if @form.valid_tos?
            render :new_tos_fields
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
        return send(:create) if devise_mapping.omniauthable? && current_organization.enabled_omniauth_providers.keys.include?(action_name.to_sym)

        raise AbstractController::ActionNotFound, "The action '#{action_name}' could not be found for Decidim::Devise::OmniauthCallbacksController"
      end

      private

      def form_params_from_pending_oauth
        submitted_params = params.fetch(:user, {}).permit(:name, :nickname, :email, :tos_agreement, :newsletter).to_h.symbolize_keys
        oauth_params = pending_oauth_form_params

        oauth_params.merge(
          submitted_params
        )
      end

      def oauth_data
        @oauth_data ||= oauth_hash.slice(:provider, :uid, :info)
      end

      # Private: Create trusted form params from oauth data stored server-side.
      # Since we are using trusted oauth data we are generating a valid signature.
      def pending_oauth_form_params
        return {} if pending_oauth_data.blank?

        {
          provider: pending_oauth_data[:provider],
          uid: pending_oauth_data[:uid],
          email: pending_oauth_data[:verified_email],
          name: pending_oauth_data[:name],
          nickname: pending_oauth_data[:nickname],
          oauth_signature: OmniauthRegistrationForm.create_signature(pending_oauth_data[:provider], pending_oauth_data[:uid]),
          avatar_url: pending_oauth_data[:avatar_url],
          raw_data: pending_oauth_data[:raw_data],
          pending_oauth_token:
        }
      end

      def verified_email
        @verified_email ||= pending_oauth_data&.dig(:verified_email)
      end

      def pending_oauth_data
        @pending_oauth_data ||= if oauth_hash.present?
                                  store_pending_oauth_data!
                                else
                                  restore_pending_oauth_data
                                end
      end

      def pending_oauth_token
        @pending_oauth_token ||= params.dig(:user, :pending_oauth_token).presence || session.dig(:omniauth_registration, :token)
      end

      def store_pending_oauth_data!
        data = {
          provider: oauth_data[:provider],
          uid: oauth_data[:uid],
          name: oauth_data.dig(:info, :name),
          nickname: oauth_data.dig(:info, :nickname),
          avatar_url: oauth_data.dig(:info, :image),
          verified_email: oauth_data.dig(:info, :email).presence,
          raw_data: oauth_hash
        }

        session[:omniauth_registration] = {
          token: SecureRandom.hex(16),
          data:
        }

        @pending_oauth_token = session[:omniauth_registration][:token]
        data
      end

      def restore_pending_oauth_data
        token = params.dig(:user, :pending_oauth_token)
        return {} if token.blank?

        state = session[:omniauth_registration]&.with_indifferent_access
        return {} if state.blank?

        stored_token = state[:token].to_s
        return {} unless stored_token.bytesize == token.to_s.bytesize
        return {} unless ActiveSupport::SecurityUtils.secure_compare(stored_token, token.to_s)

        @pending_oauth_token = stored_token
        state[:data] || {}
      end

      def clear_pending_oauth_data!
        session.delete(:omniauth_registration)
      end

      def oauth_hash
        raw_hash = request.env["omniauth.auth"]
        return {} unless raw_hash

        raw_hash.deep_symbolize_keys
      end

      def handle_missing_oauth_data!
        flash[:alert] = t("devise.failure.timeout")
        redirect_to decidim.root_path
      end
    end
  end
end

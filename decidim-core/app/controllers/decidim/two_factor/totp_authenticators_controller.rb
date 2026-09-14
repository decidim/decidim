# frozen_string_literal: true

module Decidim
  module TwoFactor
    # Enrolls the authenticator app: issues the secret, then confirms the first code.
    class TotpAuthenticatorsController < AuthenticatorsController
      def new
        enforce_permission_to(:update, :user, current_user:)

        @authenticator = TotpAuthenticator.issue_for(current_user)
        return redirect_to(two_factor_authentication_path, alert: t(".error")) if @authenticator.blank?

        @form = form(OtpCodeForm).instance
      end

      def create
        enforce_permission_to(:update, :user, current_user:)

        @authenticator = pending_totp_authenticator
        return redirect_to(two_factor_authentication_path) if @authenticator.blank?

        @form = form(OtpCodeForm).from_params(params)

        ConfirmTotp.call(@authenticator, @form) do
          on(:ok) { |recovery_codes| show_recovery_codes_or_redirect(recovery_codes, t(".success")) }

          on(:invalid) do
            flash.now[:alert] = t(".error")
            render :new, status: :unprocessable_content
          end
        end
      end

      private

      def two_factor_method = "totp"

      def pending_totp_authenticator
        current_user.two_factor_authenticators.where(confirmed_at: nil).find_by(type: TotpAuthenticator.name)
      end
    end
  end
end

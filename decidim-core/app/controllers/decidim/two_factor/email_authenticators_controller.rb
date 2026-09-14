# frozen_string_literal: true

module Decidim
  module TwoFactor
    # Enables the one-time code sent to the account email.
    class EmailAuthenticatorsController < AuthenticatorsController
      def create
        enforce_permission_to(:update, :user, current_user:)

        EnableEmailAuthenticator.call(current_user) do
          on(:ok) { |recovery_codes| show_recovery_codes_or_redirect(recovery_codes, t(".success")) }

          on(:invalid) do
            flash[:alert] = t(".error")
            redirect_to two_factor_authentication_path
          end
        end
      end

      private

      def two_factor_method = "email"
    end
  end
end

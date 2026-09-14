# frozen_string_literal: true

module Decidim
  module TwoFactor
    # Replaces the recovery codes of the user with a fresh set.
    class RecoveryCodesController < AuthenticatorsController
      def create
        enforce_permission_to(:update, :user, current_user:)
        return redirect_to(two_factor_authentication_path) unless current_user.two_factor_enabled?

        RegenerateRecoveryCodes.call(current_user) do
          on(:ok) { |recovery_codes| show_recovery_codes_or_redirect(recovery_codes, t(".success")) }
        end
      end
    end
  end
end

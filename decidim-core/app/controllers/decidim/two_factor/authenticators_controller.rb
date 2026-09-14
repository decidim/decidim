# frozen_string_literal: true

module Decidim
  module TwoFactor
    # The base controller of the second factors attached to the user's account:
    # the controller of every method inherits its checks.
    class AuthenticatorsController < Decidim::ApplicationController
      include Decidim::UserProfile

      helper SetupHelper
      helper_method :after_setup_path

      before_action :ensure_two_factor_authentication_enabled
      before_action :ensure_method_available

      def show
        redirect_to two_factor_authentication_path
      end

      def destroy
        enforce_permission_to(:update, :user, current_user:)

        RemoveAuthenticator.call(authenticator) do
          on(:ok) { flash[:notice] = t(".success") }
          on(:invalid) { flash[:alert] = t(".error") }
        end

        redirect_to two_factor_authentication_path
      end

      private

      def ensure_two_factor_authentication_enabled
        redirect_to account_path if !current_organization.two_factor_authentication_enabled? || current_user_impersonated?
      end

      def ensure_method_available
        return if two_factor_method.blank?
        return if Decidim::TwoFactor.available_methods(current_organization).map(&:name).include?(two_factor_method)

        redirect_to two_factor_authentication_path
      end

      def two_factor_method = nil

      def authenticator
        @authenticator ||= current_user.two_factor_authenticators.find_by(id: params[:id])
      end

      def after_setup_path
        @after_setup_path ||= session.delete("decidim_two_factor_return_to") || two_factor_authentication_path
      end

      def show_recovery_codes_or_redirect(recovery_codes, success_message)
        @recovery_codes = recovery_codes

        return render("decidim/two_factor/authenticators/recovery_codes") if @recovery_codes.present?

        flash[:notice] = success_message
        redirect_to two_factor_authentication_path
      end
    end
  end
end

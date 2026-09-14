# frozen_string_literal: true

module Decidim
  # The controller to handle the second factors attached to the user's account.
  class TwoFactorAuthenticationsController < Decidim::ApplicationController
    include Decidim::UserProfile

    helper TwoFactor::SetupHelper
    helper_method :two_factor_methods, :authenticators_for, :authenticator_for

    before_action :ensure_two_factor_authentication_enabled

    def show
      enforce_permission_to(:read, :user, current_user:)

      session.delete("decidim_two_factor_return_to") if current_user.two_factor_enabled?
    end

    private

    def ensure_two_factor_authentication_enabled
      redirect_to account_path if !current_organization.two_factor_authentication_enabled? || current_user_impersonated?
    end

    def two_factor_methods
      Decidim::TwoFactor.available_methods(current_organization)
    end

    def authenticators_for(manifest)
      authenticators.select { |authenticator| authenticator.type == manifest.authenticator_class_name }
    end

    def authenticator_for(manifest) = authenticators_for(manifest).first

    def authenticators
      @authenticators ||= current_user.two_factor_authenticators.to_a
    end
  end
end

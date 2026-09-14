# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # Second-factor associations and predicates for Decidim::User.
  module TwoFactorAuthenticatable
    extend ActiveSupport::Concern

    included do
      has_many :two_factor_authenticators,
               class_name: "Decidim::TwoFactor::Authenticator",
               foreign_key: "decidim_user_id",
               dependent: :destroy
      has_many :two_factor_recovery_codes,
               class_name: "Decidim::TwoFactor::RecoveryCode",
               foreign_key: "decidim_user_id",
               dependent: :destroy
    end

    def two_factor_enabled?
      two_factor_authenticators.confirmed.exists?
    end
  end
end

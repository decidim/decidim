# frozen_string_literal: true

module Decidim
  # Mails the second-factor security alerts.
  class TwoFactorMailer < ApplicationMailer
    def factors_reset(user) = deliver(user, "factors_reset")

    private

    def deliver(user, key)
      with_user(user) do
        @user = user
        @organization = user.organization
        mail(to: user.email, subject: I18n.t("decidim.two_factor_mailer.#{key}.subject"))
      end
    end
  end
end

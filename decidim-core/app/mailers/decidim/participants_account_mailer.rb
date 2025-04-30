# frozen_string_literal: true

module Decidim
  # A mailer to notify users about their account status
  class ParticipantsAccountMailer < Decidim::ApplicationMailer
    # Notify user about inactivity and potential account removal
    def inactivity_notification(user, days)
      with_user(user) do
        @user = user
        @organization = user.organization
        @days_before_deletion = days

        subject = I18n.t(
          "decidim.participants_account_mailer.inactivity_notification.subject",
          organization_name: organization_name(@organization)
        )

        mail(to: user.email, subject:)
      end
    end

    # Notify user about account removal due to inactivity
    def removal_notification(email, name, locale, organization)
      @email = email
      @user_name = name
      @organization = organization

      I18n.with_locale(locale) do
        subject = I18n.t(
          "decidim.participants_account_mailer.removal_notification.subject",
          organization_name: organization_name(@organization)
        )

        mail(to: email, subject:)
      end
    end
  end
end

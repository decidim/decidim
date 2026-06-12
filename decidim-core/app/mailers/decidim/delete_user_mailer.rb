# frozen_string_literal: true

module Decidim
  class DeleteUserMailer < ApplicationMailer
    # This email is being sent when a user deletes his own account, or when the user was inactive for too long.
    def delete(user_email:, user_name:, locale:, organization:)
      I18n.with_locale(locale) do
        @user_name = user_name
        @organization = organization
        mail(to: user_email, subject: I18n.t("decidim.delete_user_mailer.subject"))
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  class DeleteUserMailer < ApplicationMailer
    def delete(user_email:, user_name:, locale:, organization:)
      I18n.with_locale(locale) do
        @user_name = user_name
        @organization = organization
        mail(to: user_email, subject: I18n.t("decidim.delete_user_mailer.subject"))
      end
    end
  end
end

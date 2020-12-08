# frozen_string_literal: true

module Decidim
  # A custom mailer for Decidim so we can notify users
  # when their account was blocked
  class UserSuspensionMailer < ApplicationMailer
    def notify(user, token, justification)
      @user = user
      @organization = user.organization
      @token = token
      @justification = justification
      mail(
        to: user.email,
        subject: I18n.t(
          "decidim.admin.user_suspension_mailer.notify.subject",
          organization_name: @organization.name,
          justification: @justification
        )
      )
    end
  end
end

# frozen_string_literal: true

module Decidim
  # A custom mailer for Decidim so we can notify users
  # when their account was blocked
  class BlockUserMailer < ApplicationMailer
    def notify(user, justification)
      @user = user
      @organization = user.organization
      @justification = justification
      mail(
        to: user.email,
        subject: I18n.t(
          "decidim.block_user_mailer.notify.subject",
          organization_name: @organization.name,
          justification: @justification
        )
      )
    end
  end
end

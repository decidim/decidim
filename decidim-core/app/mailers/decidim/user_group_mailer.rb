# frozen_string_literal: true

module Decidim
  class UserGroupMailer < ApplicationMailer
    def notify_deprecation_to_member(user, group_name, group_email)
      with_user(user) do
        @user = user
        @group_name = group_name
        @group_email = group_email
        @organization = user.organization

        subject = I18n.t("notify_deprecation_to_member.subject", scope: "decidim.user_group_mailer")
        mail(to: user.email, subject:)
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  class UserGroupMailer < ApplicationMailer
    # This is a mailer that aids migration from the old user_groups to the new user group system
    # This should be used only in the scope of the migration process
    # @deprecated This mailer will be removed in decidim v0.32.0
    def notify_deprecation_to_owner(group)
      with_user(group) do
        @group_name = group.name
        @group_email = group.email
        @organization = group.organization

        subject = I18n.t("notify_deprecation_to_owner.subject", scope: "decidim.user_group_mailer")
        mail(to: group.email, subject:)
      end
    end

    # This is a mailer that aids migration from the old user_groups to the new user group system
    # This should be used only in the scope of the migration process
    # @deprecated This mailer will be removed in decidim v0.32.0
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

    # This is a mailer that aids migration from the old user_groups to the new user group system
    # This should be used only in the scope of the migration process
    # @deprecated This mailer will be removed in decidim v0.32.0
    def notify_user_group_patched(group, user, password)
      with_user(user) do
        @group = group
        @user = user
        @password = password
        @organization = user.organization

        subject = I18n.t("notify_user_group_patched.subject", scope: "decidim.user_group_mailer")
        mail(to: user.email, subject:)
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  class UserUpdateMailer < ApplicationMailer
    def notify(user, updates)
      with_user(user) do
        @user = user
        @organization = user.organization
        @updates = format_array(updates)
        mail(to: user.email, subject: I18n.t(
          "decidim.user_update_mailer.subject"
        ))
      end
    end

    private

    def format_array(updates)
      last_update = updates.last
      case updates.length
      when 1
        updates.first
      when 2
        I18n.t("decidim.user_update_mailer.notify.update_two_fields", updates: updates.first, last_update:, count: 2)
      else
        I18n.t("decidim.user_update_mailer.notify.update_fields", updates: updates[0..-2].join(", "), last_update:, count: updates.length)
      end
    end
  end
end

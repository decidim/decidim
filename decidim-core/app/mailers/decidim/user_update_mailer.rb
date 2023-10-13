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
      case updates.length
      when 1
        updates.first
      when 2
        "#{updates.first} and #{updates.last}"
      else
        "#{updates[0..-2].join(", ")}, and #{updates.last}"
      end
    end
  end
end

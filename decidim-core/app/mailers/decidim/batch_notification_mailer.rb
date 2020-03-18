# frozen_string_literal: true

module Decidim
  class BatchNotificationMailer < Decidim::ApplicationMailer
    helper Decidim::ResourceHelper

    def event_received(events, user)
      return if user.email.blank?

      with_user(user) do
        @organization = user.organization
        @events = events

        mail(to: user.email, subject: t(".batch_notification_subject"))
      end
    end
  end
end

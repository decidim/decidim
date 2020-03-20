# frozen_string_literal: true

module Decidim
  class BatchNotificationsMailer < Decidim::ApplicationMailer
    helper Decidim::ResourceHelper
    helper Decidim::IconHelper
    helper_method :see_more?

    def event_received(events, user)
      return if user.email.blank?

      with_user(user) do
        @user = user
        @organization = user.organization
        @events = events

        mail(to: user.email, subject: t(".batch_notification_subject", organization_name: @organization.name.html_safe))
      end
    end

    private

    def see_more?
      @events.length >= Decidim.config.batch_email_notifications_max_length
    end
  end
end

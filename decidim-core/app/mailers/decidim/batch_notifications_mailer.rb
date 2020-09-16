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
        @events = event_collection(events)

        mail(to: user.email, subject: t(".batch_notification_subject", organization_name: @organization.name.html_safe))
      end
    end

    private

    # Returns all events
    # or
    # Returns the n first events if events length is greater than batch_email_notifications_max_length
    def event_collection(events)
      return events unless events.length >= Decidim.config.batch_email_notifications_max_length

      events.take(Decidim.config.batch_email_notifications_max_length)
    end

    def see_more?
      @events.length >= Decidim.config.batch_email_notifications_max_length
    end
  end
end

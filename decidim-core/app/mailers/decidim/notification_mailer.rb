# frozen_string_literal: true

module Decidim
  # A custom mailer for sending notifications to users when
  # a events are received.
  class NotificationMailer < Decidim::ApplicationMailer
    helper Decidim::ResourceHelper
    helper Decidim::TranslationsHelper

    def event_received(event, event_class_name, resource, user, extra)
      return if user.email.blank?

      with_user(user) do
        @organization = user.organization
        event_class = event_class_name.constantize
        @event_instance = event_class.new(resource: resource, event_name: event, user: user, extra: extra)
        subject = @event_instance.email_subject
        mail(from: Decidim.config.mailer_sender, to: user.email, subject: subject)
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  # A custom mailer for sending notifications to users when
  # a events are received.
  class NotificationMailer < Decidim::ApplicationMailer
    helper Decidim::ResourceHelper

    def event_received(event, event_class_name, resource, user, extra)
      moderation = extra[:moderation_event]
      template = moderation ? "event_to_moderate_received" : "event_received"
      with_user(user) do
        @organization = resource.organization
        event_class = event_class_name.constantize
        @event_instance = event_class.new(resource: resource, event_name: event, user: user, extra: extra)
        @slug = extra[:process_slug]
        @locale = locale.to_s
        subject = moderation ? @event_instance.email_moderation_subject : @event_instance.email_subject
        @participatory_process = resource.feature.participatory_space if moderation
        mail(to: user.email, subject: subject, :template_name => template)
      end
    end
  end
end

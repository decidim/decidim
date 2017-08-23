# frozen_string_literal: true

module Decidim
  # A custom mailer for sending notifications to users when
  # a events are received.
  class NotificationMailer < Decidim::ApplicationMailer
    helper Decidim::ResourceHelper

    def event_received(event, event_class_name, resource, user)
      with_user(user) do
        @user = user
        @resource = resource
        @locator = Decidim::ResourceLocatorPresenter.new(@resource)
        @organization = resource.organization
        event_class = event_class_name.constantize
        @event_instance = event_class.new(resource)
        subject = event_instance.subject

        mail(to: user.email, subject: subject)
      end
    end
  end
end

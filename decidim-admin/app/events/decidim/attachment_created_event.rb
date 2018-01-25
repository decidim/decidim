# frozen-string_literal: true

module Decidim
  class AttachmentCreatedEvent < Decidim::Events::BaseEvent
    include Decidim::Events::EmailEvent
    include Decidim::Events::NotificationEvent

    def email_subject
      I18n.t(
        "decidim.events.attachments.attachment_created.email_subject",
        resource_title: resource_title,
        resource_path: resource_path
      )
    end

    def email_intro
      I18n.t(
        "decidim.events.attachments.attachment_created.email_intro",
        resource_title: resource_title,
        resource_path: resource_path
      )
    end

    def email_outro
      I18n.t(
        "decidim.events.attachments.attachment_created.email_outro",
        resource_title: resource_title,
        resource_path: resource_path
      )
    end

    def notification_title
      I18n.t(
        "decidim.events.attachments.attachment_created.notification_title",
        resource_title: resource_title,
        resource_path: resource_path,
        attached_to_url: attached_to_url
      ).html_safe
    end

    def resource_path
      @resource.url
    end

    def resource_url
      @resource.url
    end

    private

    def attached_to_url
      resource_locator.url
    end

    def resource
      @resource.attached_to
    end
  end
end

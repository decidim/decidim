# frozen_string_literal: true

module Decidim
  #
  # Decorator for push notifications.
  #
  class PushNotificationPresenter < SimpleDelegator
    def title
      event_class.constantize.model_name.human
    end

    def body
      # Not using Rails sanitizers here because they escape HTML entities (i.e &amp;) and we want to keep them
      Nokogiri::HTML(event_class_instance.notification_title).text if event_class_instance.notification_title.present?
    end

    def icon
      user.organization.attached_uploader(:favicon).variant_url(:big, host: user.organization.host)
    end

    def url
      resource.reported_content_url
    end
  end
end

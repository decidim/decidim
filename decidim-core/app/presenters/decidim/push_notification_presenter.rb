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
      ActionView::Base.full_sanitizer.sanitize(event_class_instance.notification_title)
    end

    def icon
      user.organization.attached_uploader(:favicon).variant_url(:big, host: user.organization.host)
    end

    def url
      resource.reported_content_url
    end
  end
end

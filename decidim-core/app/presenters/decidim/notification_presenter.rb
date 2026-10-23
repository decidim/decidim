# frozen_string_literal: true

module Decidim
  #
  # Decorator for notifications.
  #
  class NotificationPresenter < SimpleDelegator
    include ActionView::Helpers::DateHelper

    delegate :resource_text, to: :event_class_instance

    def display_resource_text?
      event_class.constantize.included_modules.include?(Decidim::Comments::CommentEvent)
    end
  end
end

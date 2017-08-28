# frozen_string_literal: true

module Decidim
  module Events
    # This module is used to be included in event classes (those inheriting from
    # `Decidim::Events::BaseEvent`) that need to create system notifications, which
    # will be later listed to the user in their Notifications Dashboard.
    #
    # This modules adds the needed logic to display these notifications.
    #
    # Example:
    #
    #   class MyEvent < Decidim::Events::BaseEvent
    #     include Decidim::Events::NotificationEvent
    #   end
    module NotificationEvent
      extend ActiveSupport::Concern

      included do
        types << :notification

        def notification_title
          "S'ha tancat la proposta <a href=\"#{resource_path}\">#{resource_title}</a>.".html_safe
        end
      end
    end
  end
end

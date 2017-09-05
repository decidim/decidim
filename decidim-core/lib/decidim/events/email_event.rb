# frozen-string_literal: true

module Decidim
  module Events
    # This module is used to be included in event classes (those inheriting from
    # `Decidim::Events::BaseEvent`) that need to send emails with the notification.
    #
    # This modules adds the needed logic to deliver emails to a given user.
    #
    # Example:
    #
    #   class MyEvent < Decidim::Events::BaseEvent
    #     include Decidim::Events::EmailEvent
    #   end
    module EmailEvent
      extend ActiveSupport::Concern

      included do
        types << :email

        def email_subject
          I18n.t("decidim.events.email_event.email_subject", resource_title: resource_title)
        end

        def email_greeting
          I18n.t("decidim.events.email_event.email_greeting", user_name: user.name)
        end

        def email_intro
          I18n.t("decidim.events.email_event.email_intro", resource_title: resource_title)
        end

        def email_outro
          I18n.t("decidim.events.email_event.email_outro", resource_title: resource_title)
        end
      end
    end
  end
end

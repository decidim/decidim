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
        type :email

        def email_subject
          I18n.t("decidim.events.email_event.email_subject", resource_title:)
        end

        def email_greeting
          I18n.t("decidim.events.email_event.email_greeting", user_name: user.name)
        end

        def email_intro
          I18n.t("decidim.events.email_event.email_intro", resource_title:)
        end

        def email_outro
          I18n.t("decidim.events.email_event.email_outro", resource_title:)
        end

        def has_button?
          button_text.present? && button_url.present?
        end

        def button_text
          nil
        end

        def button_url
          nil
        end
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  module Meetings
    class CreateMeetingEvent < Decidim::Events::SimpleEvent
      delegate :organization, to: :user, prefix: false

      def resource_text
        translated_attribute(resource.description)
      end

      def button_text
        I18n.t("meeting_created.button_text", scope: "decidim.events.meetings") if resource.can_be_joined_by?(user)
      end

      def button_url
        Decidim::EngineRouter.main_proxy(component).join_meeting_registration_url(meeting_id: resource.id, host: organization.host) if resource.can_be_joined_by?(user)
      end
    end
  end
end

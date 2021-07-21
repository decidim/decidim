# frozen_string_literal: true

module Decidim
  module Meetings
    class CreateMeetingEvent < Decidim::Events::SimpleEvent
      include Decidim::Meetings::MeetingEvent

      delegate :organization, to: :user, prefix: false

      def button_text
        I18n.t("meeting_created.button_text", scope: "decidim.events.meetings") if resource.can_be_joined_by?(user)
      end

      def button_url
        if resource.can_be_joined_by?(user)
          if resource.registration_form_enabled?
            Decidim::EngineRouter.main_proxy(component).join_meeting_registration_url(meeting_id: resource.id, host: organization.host)
          else
            Decidim::EngineRouter.main_proxy(component).meeting_url(id: resource.id, host: organization.host)
          end
        end
      end
    end
  end
end

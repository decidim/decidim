# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Meetings
     # This cell renders a project
     class RedesignedMeetingCell < Decidim::ViewModel
      include ApplicationHelper
      include Decidim::ResourceHelper
      include Decidim::TranslationsHelper
      include Decidim::LayoutHelper

      delegate :current_component, :component_settings, to: :controller

      alias meeting model

      def show
        render
      end

      private

      def tabs
        tabs = []
        tabs << { id: "participants", text: t("attending_participants", scope: "decidim.meetings.public_participants_list"), icon: "group-line" } if meeting.public_participants.any?
        tabs << { id: "organizations", text: t("organizations", scope: "decidim.meetings.meetings.show"), icon: "community-line" } if !meeting.closed? && meeting.user_group_registrations.any?
        tabs << { id: "meeting_minutes", text: t("meeting_minutes", scope: "decidim.meetings.meetings.show"), icon: "chat-new-line" } if meeting.closed? && meeting.closing_visible?
        # tabs << { id: "included_proposals", text: t("activemodel.attributes.result.proposals"), icon: "chat-new-line" }
        # tabs << { id: "included_meetings", text: t("activemodel.attributes.result.meetings_ids"), icon: "treasure-map-line" }
        tabs << { id: "images", text: "images", icon: "image-line" }
        tabs << { id: "documents", text: "documents", icon: "file-text-line" }
        tabs
      end

      def panels
        panels = []
        panels << { id: "participants", method: :cell, args: ["decidim/meetings/public_participants_list", meeting] } if meeting.public_participants.any?
        panels << { id: "organizations", method: :cell, args: ["decidim/meetings/public_participants_list", meeting] } if !meeting.closed? && meeting.user_group_registrations.any?
        panels << { id: "meeting_minutes", method: :cell, args: ["decidim/meetings/public_participants_list", meeting] } if meeting.closed? && meeting.closing_visible?
        # panels << { id: "included_proposals", method: :cell, args: ["decidim/linked_resources_for", meeting, { type: :proposals, link_name: "included_proposals" }] }
        # panels << { id: "included_meetings", method: :cell, args: ["decidim/linked_resources_for", meeting, { type: :meetings, link_name: "included_meetings" }] }
        panels << { id: "images", method: :cell, args: ["decidim/meetings/public_participants_list", meeting] }
        panels << { id: "documents", method: :cell, args: ["decidim/meetings/public_participants_list", meeting] }
        panels
      end
    end
  end
end

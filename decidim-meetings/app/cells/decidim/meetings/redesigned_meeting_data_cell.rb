# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Meetings
    # This cell renders a meeting
    class RedesignedMeetingDataCell < Decidim::ViewModel
      include ApplicationHelper
      include Decidim::ResourceHelper
      include Decidim::TranslationsHelper
      include Decidim::LayoutHelper
      include Decidim::IconHelper

      delegate :current_component, :component_settings, to: :controller
      delegate :documents, :photos, to: :model

      alias meeting model

      def show
        render
      end

      private

      def tabs
        @tabs ||= items.map { |item| item.slice(:id, :text, :icon) }
      end

      def panels
        @panels ||= items.map { |item| item.slice(:id, :method, :args) }
      end

      def items
        @items ||= [
          {
            enabled: meeting.public_participants.any?,
            id: "participants",
            text: t("attending_participants", scope: "decidim.meetings.public_participants_list"),
            icon: "group-line",
            method: :cell,
            args: ["decidim/meetings/public_participants_list", meeting]
          },
          {
            enabled: !meeting.closed? && meeting.user_group_registrations.any?,
            id: "organizations",
            text: t("attending_organizations", scope: "decidim.meetings.public_participants_list"),
            icon: "community-line",
            method: :cell,
            args: ["decidim/meetings/attending_organizations_list", meeting]
          },
          {
            enabled: meeting.linked_resources(:proposals, "proposals_from_meeting").present?,
            id: "included_proposals",
            text: t("decidim/proposals/proposal", scope: "activerecord.models", count: 2),
            icon: resource_type_icon_key("Decidim::Proposals::Proposal"),
            method: :cell,
            args: ["decidim/linked_resources_for", meeting, { type: :proposals, link_name: "proposals_from_meeting" }]
          },
          {
            enabled: meeting.linked_resources(:results, "meetings_through_proposals").present?,
            id: "included_meetings",
            text: t("decidim/accountability/result", scope: "activerecord.models", count: 2),
            icon: resource_type_icon_key("Decidim::Accountability::Result"),
            method: :cell,
            args: ["decidim/linked_resources_for", meeting, { type: :results, link_name: "meetings_through_proposals" }]
          },
          {
            enabled: photos.present?,
            id: "images",
            text: t("decidim.application.photos.photos"),
            icon: resource_type_icon_key("images"),
            method: :cell,
            args: ["decidim/images_panel", meeting]
          },
          {
            enabled: documents.present?,
            id: "documents",
            text: t("decidim.application.documents.documents"),
            icon: resource_type_icon_key("documents"),
            method: :cell,
            args: ["decidim/documents_panel", meeting]
          }
        ].select { |item| item[:enabled] }
      end
    end
  end
end

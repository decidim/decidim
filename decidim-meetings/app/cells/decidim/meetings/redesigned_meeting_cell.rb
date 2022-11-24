# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Meetings
    # This cell renders a meeting
    class RedesignedMeetingCell < Decidim::ViewModel
      include ApplicationHelper
      include Decidim::ResourceHelper
      include Decidim::TranslationsHelper
      include Decidim::LayoutHelper

      # Move to attachments independent cell:
      include Decidim::AttachmentsHelper
      include Cell::ViewModel::Partial
      include ActiveSupport::NumberHelper

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
        @items ||= [].tap do |items|
          if meeting.public_participants.any?
            items.append(
              id: "participants",
              text: t("attending_participants", scope: "decidim.meetings.public_participants_list"),
              icon: "group-line",
              method: :cell,
              args: ["decidim/meetings/public_participants_list", meeting]
            )
          end
          if !meeting.closed? && meeting.user_group_registrations.any?
            items.append(
              id: "organizations",
              text: t("organizations", scope: "decidim.meetings.meetings.show"),
              icon: "community-line",
              method: :cell,
              args: ["decidim/meetings/participating_organizations_list", meeting]
            )
          end
          if meeting.closed? && meeting.closing_visible?
            items.append(
              id: "meeting_minutes",
              text: t("meeting_minutes", scope: "decidim.meetings.meetings.show"),
              icon: "chat-new-line",
              method: :render,
              args: [:meeting_minutes]
            )
          end
          if meeting.linked_resources(:proposals, "proposals_from_meeting").present?
            items.append(
              id: "included_proposals",
              text: t("activemodel.attributes.result.proposals"),
              icon: "chat-new-line",
              method: :cell,
              args: ["decidim/linked_resources_for", meeting, { type: :proposals, link_name: "proposals_from_meeting" }]
            )
          end
          if meeting.linked_resources(:results, "meetings_through_proposals").present?
            items.append(
              id: "included_meetings",
              text: t("activemodel.attributes.result.meetings_ids"),
              icon: "treasure-map-line",
              method: :cell,
              args: ["decidim/linked_resources_for", meeting, { type: :results, link_name: "meetings_through_proposals" }]
            )
          end
          if photos.present?
            items.append(
              id: "images",
              text: t("decidim.application.photos.related_photos"),
              icon: "image-line",
              method: :render,
              args: ["images"]
            )
          end
          if documents.present?
            items.append(
              id: "documents",
              text: t("decidim.application.documents.related_documents"),
              icon: "file-text-line",
              method: :render,
              args: ["documents"]
            )
          end
        end
      end
    end
  end
end

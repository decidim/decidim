# frozen_string_literal: true

module Decidim
  module Meetings
    # This class serializes a Meeting so can be exported to CSV, JSON or other
    # formats.
    class MeetingSerializer < Decidim::Exporters::Serializer
      include Decidim::ApplicationHelper
      include Decidim::ResourceHelper

      # Public: Initializes the serializer with a meeting.
      def initialize(meeting)
        @meeting = meeting
      end

      # Public: Exports a hash with the serialized data for this meeting.
      def serialize
        {
          id: meeting.id,
          category: {
            id: meeting.category.try(:id),
            name: meeting.category.try(:name)
          },
          scope: {
            id: meeting.scope.try(:id),
            name: meeting.scope.try(:name)
          },
          participatory_space: {
            id: meeting.participatory_space.id,
            url: Decidim::ResourceLocatorPresenter.new(meeting.participatory_space).url
          },
          component: { id: component.id },
          title: meeting.title,
          description: meeting.description,
          start_time: meeting.start_time.to_s(:db),
          end_time: meeting.end_time.to_s(:db),
          attendees: meeting.attendees_count.to_i,
          contributions: meeting.contributions_count.to_i,
          organizations: meeting.attending_organizations,
          address: meeting.address,
          location: meeting.location,
          reference: meeting.reference,
          comments: meeting.comments_count,
          attachments: meeting.attachments.size,
          followers: meeting.follows.size,
          url:,
          related_proposals:,
          related_results:,
          published: meeting.published_at.present?
        }
      end

      private

      attr_reader :meeting
      alias resource meeting

      def component
        meeting.component
      end

      def related_proposals
        meeting.linked_resources(:proposals, "proposals_from_meeting").map do |proposal|
          Decidim::ResourceLocatorPresenter.new(proposal).url
        end
      end

      def related_results
        meeting.linked_resources(:results, "meetings_through_proposals").map do |result|
          Decidim::ResourceLocatorPresenter.new(result).url
        end
      end

      def url
        Decidim::ResourceLocatorPresenter.new(meeting).url
      end
    end
  end
end

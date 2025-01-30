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
          author: {
            **author_fields
          },
          participatory_space: {
            id: meeting.participatory_space.id,
            url: Decidim::ResourceLocatorPresenter.new(meeting.participatory_space).url
          },
          taxonomies:,
          component: { id: component.id },
          title: meeting.title,
          description: meeting.description,
          start_time: meeting.start_time,
          end_time: meeting.end_time,
          attendees: meeting.attendees_count.to_i,
          contributions: meeting.contributions_count.to_i,
          organizations: meeting.attending_organizations,
          address: meeting.address,
          location: include_location? ? meeting.location : nil,
          reference: meeting.reference,
          attachments: meeting.attachments.size,
          url:,
          related_proposals:,
          related_results:,
          published: meeting.published_at.present?,
          withdrawn: meeting.withdrawn?,
          withdrawn_at: meeting.withdrawn_at,
          location_hints: meeting.location_hints,
          created_at: meeting.created_at,
          updated_at: meeting.updated_at,
          latitude: meeting.latitude,
          longitude: meeting.longitude,
          follows_count: meeting.follows_count,
          private_meeting: meeting.private_meeting,
          transparent: meeting.transparent,
          registration_form_enabled: meeting.registration_form_enabled,
          comments: {
            **comment_fields
          },
          online_meeting_url: meeting.online_meeting_url,
          closing_visible: meeting.closing_visible,
          closing_report: meeting.closing_report,
          attending_organizations: meeting.attending_organizations,
          registration_url: meeting.registration_url,
          decidim_user_group_id: meeting.decidim_user_group_id,
          decidim_author_type: meeting.decidim_author_type,
          video_url: meeting.video_url,
          audio_url: meeting.audio_url,
          closed_at: meeting.closed_at,
          registration_terms: meeting.registration_terms,
          available_slots: meeting.available_slots,
          registrations_enabled: meeting.registrations_enabled,
          customize_registration_email: meeting.customize_registration_email,
          type_of_meeting: meeting.type_of_meeting,
          iframe_access_level: meeting.iframe_access_level,
          iframe_embed_type: meeting.iframe_embed_type,
          reserved_slots: meeting.reserved_slots,
          registration_type: meeting.registration_type
        }
      end

      private

      attr_reader :meeting
      alias resource meeting

      def author_fields
        {
          id: meeting.author.id,
          name: author_name(meeting.author),
          url: author_url(meeting.author)
        }
      end

      def author_name(author)
        translated_attribute(author.name)
      end

      def author_url(author)
        if author.respond_to?(:nickname)
          profile_url(author) # is a Decidim::User or Decidim::UserGroup
        else
          root_url # is a Decidim::Organization
        end
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

      def comment_fields
        return {} unless meeting.comments

        {
          start_time: meeting.comments_start_time,
          end_time: meeting.comments_end_time,
          enabled: meeting.comments_enabled,
          count: meeting.comments_count
        }
      end

      def include_location?
        meeting.iframe_access_level == "all"
      end
    end
  end
end

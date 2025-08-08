# frozen_string_literal: true

module Decidim
  module Meetings
    # This class serializes a Meeting so can be exported to CSV, JSON or other
    # formats.
    class MeetingSerializer < Decidim::Exporters::Serializer
      include Decidim::ApplicationHelper
      include Decidim::ResourceHelper

      # Public: Exports a hash with the serialized data for this meeting.
      def serialize
        {
          id: resource.id,
          author: {
            **author_fields
          },
          participatory_space: {
            id: resource.participatory_space.id,
            url: Decidim::ResourceLocatorPresenter.new(resource.participatory_space).url
          },
          taxonomies:,
          component: { id: component.id },
          title: resource.title,
          description: resource.description,
          start_time: resource.start_time,
          end_time: resource.end_time,
          attendees: resource.attendees_count.to_i,
          contributions: resource.contributions_count.to_i,
          organizations: resource.attending_organizations,
          address: resource.address,
          location: include_location? ? resource.location : nil,
          reference: resource.reference,
          attachments: resource.attachments.size,
          url:,
          related_proposals:,
          related_results:,
          published: resource.published_at.present?,
          withdrawn: resource.withdrawn?,
          withdrawn_at: resource.withdrawn_at,
          location_hints: resource.location_hints,
          created_at: resource.created_at,
          updated_at: resource.updated_at,
          latitude: resource.latitude,
          longitude: resource.longitude,
          follows_count: resource.follows_count,
          private_meeting: resource.private_meeting,
          transparent: resource.transparent,
          registration_form_enabled: resource.registration_form_enabled,
          comments: {
            **comment_fields
          },
          online_meeting_url: resource.online_meeting_url,
          closing_visible: resource.closing_visible,
          closing_report: resource.closing_report,
          attending_organizations: resource.attending_organizations,
          registration_url: resource.registration_url,
          decidim_author_type: resource.decidim_author_type,
          video_url: resource.video_url,
          audio_url: resource.audio_url,
          closed_at: resource.closed_at,
          registration_terms: resource.registration_terms,
          available_slots: resource.available_slots,
          registrations_enabled: resource.registrations_enabled,
          customize_registration_email: resource.customize_registration_email,
          type_of_meeting: resource.type_of_meeting,
          iframe_access_level: resource.iframe_access_level,
          iframe_embed_type: resource.iframe_embed_type,
          reserved_slots: resource.reserved_slots,
          registration_type: resource.registration_type
        }
      end

      private

      def author_fields
        {
          id: resource.author.id,
          name: author_name(resource.author),
          url: author_url(resource.author)
        }
      end

      def author_name(author)
        translated_attribute(author.name)
      end

      def author_url(author)
        if author.respond_to?(:nickname)
          profile_url(author) # is a Decidim::User
        else
          root_url # is a Decidim::Organization
        end
      end

      def related_proposals
        resource.linked_resources(:proposals, "proposals_from_meeting").map do |proposal|
          Decidim::ResourceLocatorPresenter.new(proposal).url
        end
      end

      def related_results
        resource.linked_resources(:results, "meetings_through_proposals").map do |result|
          Decidim::ResourceLocatorPresenter.new(result).url
        end
      end

      def url
        Decidim::ResourceLocatorPresenter.new(resource).url
      end

      def comment_fields
        return {} unless resource.comments

        {
          start_time: resource.comments_start_time,
          end_time: resource.comments_end_time,
          enabled: resource.comments_enabled,
          count: resource.comments_count
        }
      end

      def include_location?
        resource.iframe_access_level == "all"
      end
    end
  end
end

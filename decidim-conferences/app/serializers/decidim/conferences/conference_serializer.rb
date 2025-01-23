# frozen_string_literal: true

module Decidim
  module Conferences
    # This class serializes a Conference so it can be exported to CSV, JSON or other formats.
    class ConferenceSerializer < Decidim::Conferences::OpenDataConferenceSerializer
      # Public: Exports a hash with the serialized data for this conference.
      def serialize
        super.merge(
          {
            taxonomies:,
            attachments: {
              attachment_collections: serialize_attachment_collections,
              files: serialize_attachments
            },
            weight: resource.weight,
            components: serialize_components
          }
        )
      end
    end
  end
end

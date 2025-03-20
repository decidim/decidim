# frozen_string_literal: true

module Decidim
  # This class serializes a Report so can be exported to CSV
  module DownloadYourDataSerializers
    class DownloadYourDataReportSerializer < Decidim::Exporters::Serializer
      include Decidim::ResourceHelper

      # Public: Exports a hash with the serialized data for this conversation.
      def serialize
        {
          id: resource.id,
          moderation: {
            id: resource.moderation.id,
            participatory_space: {
              id: resource.moderation.decidim_participatory_space_id,
              type: resource.moderation.decidim_participatory_space_type,
              title: resource.moderation.participatory_space.title
            },
            reportable_element: {
              id: resource.moderation.decidim_reportable_id,
              type: resource.moderation.decidim_reportable_type
            },
            hidden_at: resource.moderation.hidden_at,
            created_at: resource.moderation.created_at,
            updated_at: resource.moderation.updated_at
          },
          reason: resource.reason,
          details: resource.details,
          created_at: resource.created_at,
          updated_at: resource.updated_at
        }
      end
    end
  end
end

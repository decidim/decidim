# frozen_string_literal: true

module Decidim
  # This class serializes a Follow so can be exported to CSV
  module DownloadYourDataSerializers
    class DownloadYourDataFollowSerializer < Decidim::Exporters::Serializer
      include Decidim::ResourceHelper

      # Public: Exports a hash with the serialized data for follow.
      def serialize
        {
          id: resource.id,
          followable: {
            id: resource.decidim_followable_id,
            type: resource.decidim_followable_type
          },
          created_at: resource.created_at,
          updated_at: resource.updated_at
        }
      end
    end
  end
end

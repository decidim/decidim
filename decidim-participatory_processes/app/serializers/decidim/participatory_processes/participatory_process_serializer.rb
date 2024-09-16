# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This class serializes a ParticipatoryProcesses so can be exported to CSV, JSON or other
    # formats.
    class ParticipatoryProcessSerializer < Decidim::ParticipatoryProcesses::OpenDataParticipatoryProcessSerializer
      # Public: Exports a hash with the serialized data for this participatory_process.
      def serialize
        super.merge(
          {
            categories: serialize_categories,
            attachments: {
              attachment_collections: serialize_attachment_collections,
              files: serialize_attachments
            },
            private_space: resource.private_space,
            weight: resource.weight,
            components: serialize_components
          }
        )
      end
    end
  end
end

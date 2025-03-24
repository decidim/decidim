# frozen_string_literal: true

module Decidim
  module Assemblies
    # This class serializes an Assembly so it can be exported to CSV, JSON or other formats.
    class AssemblySerializer < Decidim::Assemblies::OpenDataAssemblySerializer
      # Public: Exports a hash with the serialized data for this assembly.
      def serialize
        super.merge(
          {
            categories: serialize_categories,
            taxonomies:,
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

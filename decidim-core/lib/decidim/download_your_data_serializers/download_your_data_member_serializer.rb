# frozen_string_literal: true

module Decidim
  # This class serializes a User so can be exported to CSV
  module DownloadYourDataSerializers
    class DownloadYourDataMemberSerializer < Decidim::Exporters::Serializer
      include Decidim::ResourceHelper

      # Public: Exports a hash with the serialized data for this user.
      def serialize
        {
          id: resource.id,
          participatory_space: {
            id: resource.participatory_space_id,
            type: resource.participatory_space_type,
            title: resource.participatory_space.title,
            slug: resource.participatory_space.slug
          },
          created_at: resource.created_at,
          updated_at: resource.updated_at,
          role: resource.role,
          published: resource.published
        }
      end
    end
  end
end

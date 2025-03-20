# frozen_string_literal: true

module Decidim
  # This class serializes a User so can be exported to CSV
  module DownloadYourDataSerializers
    class DownloadYourDataParticipatorySpacePrivateUserSerializer < Decidim::Exporters::Serializer
      include Decidim::ResourceHelper

      # Public: Exports a hash with the serialized data for this user.
      def serialize
        {
          id: resource.id,
          privatable_to: {
            id: resource.privatable_to_id,
            type: resource.privatable_to_type,
            title: resource.privatable_to.title,
            slug: resource.privatable_to.slug
          },
          created_at: resource.created_at,
          updated_at: resource.updated_at
        }
      end
    end
  end
end

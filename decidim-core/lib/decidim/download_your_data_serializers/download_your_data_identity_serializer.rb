# frozen_string_literal: true

module Decidim
  # This class serializes a Identity so can be exported to CSV
  module DownloadYourDataSerializers
    class DownloadYourDataIdentitySerializer < Decidim::Exporters::Serializer
      include Decidim::ResourceHelper

      # Public: Exports a hash with the serialized data for this identities.
      def serialize
        {
          id: resource.id,
          provider: resource.provider,
          uid: resource.uid,
          user: {
            id: resource.user.id,
            name: resource.user.name
          },
          created_at: resource.created_at,
          updated_at: resource.updated_at
        }
      end
    end
  end
end

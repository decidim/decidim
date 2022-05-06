# frozen_string_literal: true

module Decidim
  # This class serializes a User so can be exported to CSV
  module DownloadYourDataSerializers
    class DownloadYourDataUserGroupSerializer < Decidim::Exporters::Serializer
      include Decidim::ResourceHelper

      # Public: Exports a hash with the serialized data for this user.
      def serialize
        {
          id: resource.id,
          name: resource.name,
          document_number: resource.document_number,
          phone: resource.phone,
          verified_at: resource.verified_at
        }
      end
    end
  end
end

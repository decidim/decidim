# frozen_string_literal: true

module Decidim
  # This class serializes a Follow so can be exported to CSV
  module DownloadYourDataSerializers
    class DownloadYourDataNotificationSerializer < Decidim::Exporters::Serializer
      include Decidim::ResourceHelper

      # Public: Exports a hash with the serialized data for follow.
      def serialize
        {
          id: resource.id,
          resource_type: {
            id: resource.decidim_resource_id,
            type: resource.decidim_resource_type
          },
          event_name: resource.event_name,
          event_class: resource.event_class,
          created_at: resource.created_at,
          updated_at: resource.updated_at,
          extra: resource.extra
        }
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  # This class serializes a Message so can be exported to CSV
  module Exporters
    class DataPortabilityMessageSerializer < Decidim::Exporters::Serializer
      include Decidim::ResourceHelper

      # Public: Exports a hash with the serialized data for this conversation.
      def serialize
        {
          # id: resource.id,
          conversation: resource.conversation.id,
          sender: {
            id: resource.sender.id,
            name: resource.sender.name,
          },
          body: resource.body,
          created_at: resource.created_at,
          updated_at: resource.updated_at
        }
      end
    end
  end
end

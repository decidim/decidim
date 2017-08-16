# frozen_string_literal: true

module Decidim
  module Meetings
    class InscriptionSerializer < Decidim::Exporters::Serializer
      # Serializes a inscription
      def serialize
        {
          id: resource.id,
          user: {
            name: resource.user.name
          }
        }
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  module Initiatives
    class OpenDataInitiativeSerializer < Decidim::Exporters::Serializer
      # Serializes an initiative
      def serialize
        {
          id: resource.id,
          title: resource.title,
          description: resource.description,
          state: resource.state,
          created_at: resource.created_at,
          published_at: resource.published_at,
          signature_end_date: resource.signature_end_date,
          signature_type: resource.signature_type,
          signatures: resource.supports_count,
          scope: {
            id: resource.scope&.id, 
            name: resource.scope&.name
          },
          type: {
            id: resource.type&.id,
            title: resource.type&.title
          },
          authors: {
            id: resource.author_users.map(&:id),
            name: resource.author_users.map(&:name)
          },
          area: {
            id: resource.area&.id,
            name: resource.area&.name
          }
        }
      end
    end
  end
end

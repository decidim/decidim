# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    class DocumentsType < Decidim::Core::ComponentType
      graphql_name "CollaborativeTexts"
      description "A collaborative texts component of a participatory space."

      field :collaborative_text, Decidim::CollaborativeTexts::DocumentType, "A single CollaborativeText object", null: true do
        argument :id, GraphQL::Types::ID, "The id of the CollaborativeText requested", required: true
      end
      field :collaborative_texts, Decidim::CollaborativeTexts::DocumentType.connection_type, "A collection of CollaborativeTexts", null: true, connection: true

      def collaborative_texts
        Document.published.where(component: object).includes(:component)
      end

      def collaborative_text(**args)
        Document.published.where(component: object).find_by(id: args[:id])
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    class DocumentsType < Decidim::Core::ComponentType
      graphql_name "CollaborativeTexts"
      description "A collaborative texts component of a participatory space."

      field :collaborative_text, Decidim::CollaborativeTexts::DocumentType, "A single CollaborativeText object", null: true do
        argument :id, GraphQL::Types::ID, "The id of the CollaborativeText requested", required: true
      end

      field :collaborative_texts, Decidim::CollaborativeTexts::DocumentType.connection_type, "A collection of CollaborativeTexts", null: false, connection: true do
        argument :filter, Decidim::CollaborativeTexts::DocumentInputFilter, "Provides several methods to filter the results", required: false
        argument :order, Decidim::CollaborativeTexts::DocumentInputSort, "Provides several methods to order the results", required: false
      end

      def collaborative_texts(filter: {}, order: {})
        base_query = Decidim::Core::ComponentListBase.new(model_class: Document).call(object, { filter:, order: }, context)
        if context[:current_user]&.admin?
          base_query
        else
          base_query.published
        end
      end

      def collaborative_text(id:)
        scope =
          if context[:current_user]&.admin?
            Document
          else
            Document.published
          end

        Decidim::Core::ComponentFinderBase.new(model_class: scope).call(object, { id: }, context)
      end
    end
  end
end

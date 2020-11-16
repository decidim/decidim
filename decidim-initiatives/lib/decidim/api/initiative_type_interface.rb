# frozen_string_literal: true

module Decidim
  module Initiatives
    # This interface represents a commentable object.

    module InitiativeTypeInterface
      include GraphQL::Schema::Interface
      # name "InitiativeTypeInterface"
      description "An interface that can be used in Initiative objects."

      field :initiativeType, Decidim::Initiatives::InitiativeApiType, null: true, description: "The object's initiative type"

      def initiativeType
        object.type
      end
    end
  end
end

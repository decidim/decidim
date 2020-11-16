# frozen_string_literal: true

module Decidim
  module Core
    class AmendmentType < GraphQL::Schema::Object
      graphql_name "Amendment"
      description "An amendment"

      field :id, GraphQL::Types::ID, null: false, description: "The id of this amendment"
      field :state, GraphQL::Types::String, null: false, description: "The status of this amendment"
      field :amender, Decidim::Core::AuthorInterface, null: false, description: "The author of this amendment"
      field :amendableType, GraphQL::Types::String, null: true, description: "Type of the amendable object"
      field :emendationType, String, null: false, description: "Type of the emendation object"

      field :amendable, AmendableEntityInterface, null: false, description: "The original amended resource (currently, a proposal only)"
      field :emendation, AmendableEntityInterface, null: false, description: "The emendation (currently, a proposal only)"

      def amendableType
        object.decidim_amendable_type
      end

      def emendationType
        object.decidim_emendation_type
      end
    end
  end
end

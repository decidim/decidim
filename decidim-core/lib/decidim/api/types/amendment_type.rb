# frozen_string_literal: true

module Decidim
  module Core
    class AmendmentType < Decidim::Api::Types::BaseObject
      description "An amendment"

      field :id, GraphQL::Types::ID, "The id of this amendment", null: false
      field :state, GraphQL::Types::String, "The status of this amendment", null: false
      field :amender, Decidim::Core::AuthorInterface, "The author of this amendment", null: false

      field :amendable_type, GraphQL::Types::String, method: :decidim_amendable_type, description: "Type of the amendable object", null: false
      field :emendation_type, GraphQL::Types::String, method: :decidim_emendation_type, description: "Type of the emendation object", null: false

      field :amendable, AmendableEntityInterface, "The original amended resource (currently, a proposal only)", null: false
      field :emendation, AmendableEntityInterface, "The emendation (currently, a proposal only)", null: false
    end
  end
end

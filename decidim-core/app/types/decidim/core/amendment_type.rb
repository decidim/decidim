# frozen_string_literal: true

module Decidim
  module Core
    AmendmentType = GraphQL::ObjectType.define do
      name "Amendment"
      description "An amendment"

      field :id, !types.ID, "The id of this amendment"
      field :state, !types.String, "The status of this amendment"
      field :amender, !Decidim::Core::AuthorInterface, "The author of this amendment"

      field :amendableType, !types.String do
        description "Type of the amendable object"
        property :decidim_amendable_type
      end
      field :emendationType, !types.String do
        description "Type of the emendation object"
        property :decidim_emendation_type
      end

      field :amendable, !AmendableEntityInterface, "The original amended resource (currently, a proposal only)"
      field :emendation, !AmendableEntityInterface, "The emendation (currently, a proposal only)"
    end
  end
end

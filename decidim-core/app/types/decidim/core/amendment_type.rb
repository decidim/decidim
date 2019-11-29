# frozen_string_literal: true

module Decidim
  module Core
    AmendmentType = GraphQL::ObjectType.define do
      name "Amendment"
      description "An amendment"

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

      # Currently there are only proposals, when this changes
      # we will have to take a look at unions:
      # https://github.com/rmosolgo/graphql-ruby/blob/master/guides/type_definitions/unions.md
      field :amendable, !Decidim::Proposals::ProposalType, "The original amended resource (currently, a proposal only)"
      field :emendation, !Decidim::Proposals::ProposalType, "The emendation (currently, a proposal only)"
    end
  end
end

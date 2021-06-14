# frozen_string_literal: true

module Decidim
  module Elections
    # This type represents a bulletin board closure for an election.
    class BulletinBoardClosureType < Decidim::Api::Types::BaseObject
      description "A bulletin board election closure"

      field :id, GraphQL::Types::ID, "The internal ID of this result", null: false
      field :created_at, Decidim::Core::DateTimeType, "When this result was created", null: true
      field :updated_at, Decidim::Core::DateTimeType, "When this result was updated", null: true
      field :election, Decidim::Elections::ElectionType, "The election for this closure", null: false
      field :results, [Decidim::Elections::ElectionResultType, { null: true }], "The results for this closure", null: false
    end
  end
end

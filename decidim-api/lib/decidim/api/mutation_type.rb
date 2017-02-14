# frozen_string_literal: true
module Decidim
  module Api
    # This type represents the root mutation type of the whole API
    MutationType = GraphQL::ObjectType.define do
      name "Mutation"
      description "The root mutation of this schema"
    end
  end
end

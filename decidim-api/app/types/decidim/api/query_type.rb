# frozen_string_literal: true
module Decidim
  module Api
    # This type represents the root type of the whole API.
    QueryType = GraphQL::ObjectType.define do
      name "Query"
      description "The root query of this schema"

      field :processes do
        type !types[ProcessType]
        description "Lists all processes."

        resolve ->(_obj, _args, ctx) {
          ctx[:current_organization].participatory_processes
        }
      end
    end
  end
end

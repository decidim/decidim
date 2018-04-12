# frozen_string_literal: true

module Decidim
  module Core
    OrganizationType = GraphQL::ObjectType.define do
      name "Organization"
      description "The current organization"

      field :name, types.String, "The name of the current organization"

      field :stats do
        type types[Core::StatisticType]
        description "The statistics associated to this object"
        resolve ->(object, _args, _ctx) {
          Decidim.stats.with_context(object)
        }
      end
    end
  end
end

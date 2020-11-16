# frozen_string_literal: true

module Decidim
  module Core
    class OrganizationType < GraphQL::Schema::Object
      graphql_name   "Organization"
      description "The current organization"

      field :name, String, null: true, description: "The name of the current organization"
      field :stats , [Core::StatisticType], null: true, description: "The statistics associated to this object"

      def stats
        Decidim.stats.with_context(object)
      end
    end
  end
end

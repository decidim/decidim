# frozen_string_literal: true

module Decidim
  module Core
    class StatisticType < GraphQL::Schema::Object
      graphql_name "Statistic"
      description "Represents a single statistic"

      field :name, String, null: false, description: "The name of the statistic"do
        def resolve_field(object, args, context)
          object[0]
        end
      end
      field :value, Int, null: false, description: "The actual value of the statistic"do
        def resolve_field(object, args, context)
          object[1]
        end
      end
    end
  end
end

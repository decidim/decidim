# frozen_string_literal: true

module Decidim
  module Core
    class StatisticType   < GraphQL::Schema::Object
      graphql_name "Statistic"
      description "Represents a single statistic"

      field :name, String, null: false, description: "The name of the statistic"
      field :value, Int,  null: false, description:"The actual value of the statistic"

      def value
          statistic[1]
      end

      def name
        statistic[0]
      end
    end
  end
end

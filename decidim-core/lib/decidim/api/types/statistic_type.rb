# frozen_string_literal: true

module Decidim
  module Core
    class StatisticType < Decidim::Api::Types::BaseObject
      description "Represents a single statistic"

      field :name, GraphQL::Types::String, "The name of the statistic", null: false
      field :value, GraphQL::Types::Int, "The actual value of the statistic", null: false

      def name
        object[0]
      end

      def value
        object[1]
      end
    end
  end
end

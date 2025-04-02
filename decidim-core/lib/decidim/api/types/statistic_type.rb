# frozen_string_literal: true

module Decidim
  module Core
    class StatisticType < Decidim::Api::Types::BaseObject
      description "Represents a single statistic"

      field :icon_name, GraphQL::Types::String, "The name of the statistic icon", null: false
      field :name, GraphQL::Types::String, "The name of the statistic", null: false
      field :tooltip_key, GraphQL::Types::String, "The description of the statistic calculation", null: false
      field :value, GraphQL::Types::Int, "The actual value of the statistic", null: false, hash_key: :data
    end
  end
end

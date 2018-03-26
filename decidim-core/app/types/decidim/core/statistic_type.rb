# frozen_string_literal: true

module Decidim
  module Core
    StatisticType = GraphQL::ObjectType.define do
      name "Statistic"
      description "Represents a single statistic"

      field :name, !types.String, "The name of the statistic" do
        resolve ->(statistic, _args, _ctx) {
          statistic[0]
        }
      end

      field :value, !types.Int, "The actual value of the statistic" do
        resolve ->(statistic, _args, _ctx) {
          statistic[1]
        }
      end
    end
  end
end

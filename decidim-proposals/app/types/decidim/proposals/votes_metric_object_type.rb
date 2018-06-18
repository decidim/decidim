# frozen_string_literal: true

module Decidim
  module Proposals
    VotesMetricObjectType = GraphQL::ObjectType.define do
      interfaces [ -> { VotesMetricObjectInterface } ]

      name "VotesMetricObjectType"
      description "VotesMetric object data"
    end
  end
end

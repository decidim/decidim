# frozen_string_literal: true

module Decidim
  module Comments
    CommentsMetricType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Core::MetricInterface }]

      name "CommentsMetricType"
      description "A Comment component of a participatory space."
    end
  end
end

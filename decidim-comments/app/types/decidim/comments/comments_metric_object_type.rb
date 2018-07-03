# frozen_string_literal: true

module Decidim
  module Comments
    CommentsMetricObjectType = GraphQL::ObjectType.define do
      interfaces [-> { CommentsMetricObjectInterface }]

      name "CommentsMetricObject"
      description "CommentsMetric object data"
    end
  end
end

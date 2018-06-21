# frozen_string_literal: true

module Decidim
  module Comments
    CommentMetricObjectType = GraphQL::ObjectType.define do
      interfaces [-> { CommentMetricObjectInterface }]

      name "CommentMetricObject"
      description "CommentMetric object data"
    end
  end
end

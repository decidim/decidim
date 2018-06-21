# frozen_string_literal: true

module Decidim
  module Comments
    CommentMetricInterface = GraphQL::InterfaceType.define do
      name "CommentMetricInterface"
      description "CommentMetric definition"

      field :count, !types.Int, "Total comments"

      field :data, !types[CommentMetricObjectType], "Data for each comment"

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end

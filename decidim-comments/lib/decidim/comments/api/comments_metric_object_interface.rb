# frozen_string_literal: true

module Decidim
  module Comments
    CommentsMetricObjectInterface = GraphQL::InterfaceType.define do
      name "CommentsMetricObjectInterface"
      description "CommentsMetric object definition"

      field :created_at, !types.String, "Created at date" do
        resolve ->(obj, _args, _ctx) { MetricObjectPresenter.new(obj).attr_date(:created_at) }
      end

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end

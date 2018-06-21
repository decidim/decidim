# frozen_string_literal: true

module Decidim
  module Comments
    CommentMetricObjectInterface = GraphQL::InterfaceType.define do
      name "CommentMetricObjectInterface"
      description "CommentMetric object definition"

      # field :title, !types.String, "Published at date" do
      #   resolve ->(obj, _args, _ctx) { MetricObjectPresenter.new(obj).attr_string(:title) }
      # end

      field :created_at, !types.String, "Created at date" do
        resolve ->(obj, _args, _ctx) { MetricObjectPresenter.new(obj).attr_date(:created_at) }
      end

      # field :state, !types.String, "current state" do
      #   resolve ->(obj, _args, _ctx) { MetricObjectPresenter.new(obj).attr_string(:state, default: "published") }
      # end
      #
      # field :category, !types.String, "category" do
      #   resolve ->(obj, _args, _ctx) { MetricObjectPresenter.new(obj.category).attr_translated(:name) }
      # end

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end

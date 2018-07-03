# frozen_string_literal: true

module Decidim
  module Proposals
    VotesMetricObjectInterface = GraphQL::InterfaceType.define do
      name "VotesMetricObjectInterface"
      description "VotesMetric object definition"

      field :created_at, !types.String, "Published at date" do
        resolve ->(obj, _args, _ctx) { MetricObjectPresenter.new(obj).attr_date(:created_at) }
      end

      field :proposal, !ProposalsMetricObjectType, "Vote proposal"

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end

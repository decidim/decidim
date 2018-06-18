# frozen_string_literal: true

module Decidim
  module Proposals
    VotesMetricObjectInterface = GraphQL::InterfaceType.define do
      name "VotesMetricObjectInterface"
      description "VotesMetric object definition"

      field :created_at, !types.String, "Published at date" do
        resolve ->(obj, _args, _ctx) { VotePresenter.new(obj).created_at_date }
      end

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end

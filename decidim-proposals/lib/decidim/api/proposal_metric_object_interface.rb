# frozen_string_literal: true

module Decidim
  module Proposals
    ProposalMetricObjectInterface = GraphQL::InterfaceType.define do
      name "ProposalMetricObjectInterface"
      description "ProposalMetric object definition"

      field :published_at, !types.String, "Published at date" do
        resolve ->(obj, _args, _ctx) { ProposalPresenter.new(obj).published_at_date }
      end

      field :state, !types.String, "current state" do
        resolve ->(obj, _args, _ctx) { ProposalPresenter.new(obj).state }
      end

      field :category, !Decidim::Core::CategoryType, "category"

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end

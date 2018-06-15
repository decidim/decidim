# frozen_string_literal: true

module Decidim
  module Core
    UserMetricObjectInterface = GraphQL::InterfaceType.define do
      name "UserMetricObjectInterface"
      description "UserMetric object definition"

      field :confirmed_at, !types.String, "Confirmed at date" do
        resolve ->(obj, _args, _ctx) { UserPresenter.new(obj).confirmed_at_date }
      end

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end

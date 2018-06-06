# frozen_string_literal: true

module Decidim
  module Core
    DataVizzInterface = GraphQL::InterfaceType.define do
      name "DataVizzInterface"
      description "The interface that all DataVizz data."

      field :count, !types.Int, "Counter"

      field :data, !types.String, "Data"

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end

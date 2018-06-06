# frozen_string_literal: true

module Decidim
  module Core

    DataVizzType = GraphQL::ObjectType.define do
      interfaces [-> { DataVizzInterface }]

      name "DataVizz"
      description "The Data Visualization structure"

      field :count, !types.Int, "Counter of results" do
        resolve ->(obj, _args, _ctx) { obj.is_a?(Enumerable) ? obj.count : 1 }
      end

      field :data, !types.String, "Stringify data" do
        resolve ->(obj, _args, _ctx) { obj.respond_to?(:as_json) ? obj.as_json : "" }
      end

    end
  end
end

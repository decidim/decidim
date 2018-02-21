# frozen_string_literal: true

module Decidim
  module Core
    DateType = GraphQL::ScalarType.define do
      name "DateTime"
      description "An ISO8601 date"

      coerce_input ->(value, _ctx) do
        Date.iso8601(value)
      end

      coerce_result ->(value, _ctx) { value.to_date.iso8601 }
    end
  end
end

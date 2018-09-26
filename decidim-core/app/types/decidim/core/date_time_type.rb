# frozen_string_literal: true

module Decidim
  module Core
    DateTimeType = GraphQL::ScalarType.define do
      name "DateTime"
      description "An ISO8601 date with time"
      coerce_input ->(value, _ctx) { Time.iso8601(value) }
      coerce_result ->(value, _ctx) { value.to_time.iso8601 }
    end
  end
end

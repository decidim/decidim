# frozen_string_literal: true

module Decidim
  module Core
    class DateTimeType  < GraphQL::Schema::Scalar
      graphql_name  "DateTime"
      description "An ISO8601 date with time"

      def coerce_input(value, ctx)
        Time.iso8601(value)
      end

      def coerce_result(value, ctx)
        value.to_time.iso8601
      end
    end
  end
end

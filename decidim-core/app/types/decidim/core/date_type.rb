# frozen_string_literal: true

module Decidim
  module Core
    class DateType < GraphQL::Schema::Scalar
      graphql_name "Date"
      description "An ISO8601 date"

      def coerce_input(value, ctx)
        Date.iso8601(value)
      end

      def coerce_result(value, ctx)
        value.to_date.iso8601
      end

    end
  end
end

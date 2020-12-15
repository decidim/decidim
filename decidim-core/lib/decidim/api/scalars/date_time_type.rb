# frozen_string_literal: true

module Decidim
  module Core
    class DateTimeType < Decidim::Api::Types::BaseScalar
      description "An ISO8601 date with time"

      def self.coerce_input(value, _ctx)
        Time.iso8601(value)
      end

      def self.coerce_result(value, _ctx)
        value.to_time.iso8601
      end
    end
  end
end

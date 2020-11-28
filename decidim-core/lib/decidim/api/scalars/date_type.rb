# frozen_string_literal: true

module Decidim
  module Core
    class DateType < Decidim::Api::Types::BaseScalar
      description "An ISO8601 date"

      def self.coerce_input(value, _ctx)
        Date.iso8601(value)
      end

      def self.coerce_result(value, _ctx)
        value.to_date.iso8601
      end
    end
  end
end

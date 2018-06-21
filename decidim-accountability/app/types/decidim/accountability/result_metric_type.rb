# frozen_string_literal: true

module Decidim
  module Accountability
    ResultMetricType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Accountability::ResultMetricInterface }]

      name "ResultMetricType"
      description "A result component of a participatory space."
    end

    module ResultMetricTypeHelper
      def self.base_scope(_organization)
        Result.includes(:category, :status).all
      end
    end
  end
end

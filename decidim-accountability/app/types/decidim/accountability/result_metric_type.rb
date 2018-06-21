# frozen_string_literal: true

module Decidim
  module Accountability
    ResultMetricType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Accountability::ResultMetricInterface }]

      name "ResultMetricType"
      description "A result component of a participatory space."

      field :count, !types.Int, "Total results" do
        resolve ->(organization, _args, _ctx) {
          ResultMetricTypeHelper.base_scope(organization).count
        }
      end

      field :data, !types[ResultMetricObjectType], "Data for each result" do
        resolve ->(organization, _args, _ctx) {
          ResultMetricTypeHelper.base_scope(organization)
        }
      end
    end

    module ResultMetricTypeHelper
      def self.base_scope(_organization)
        Result.includes(:category, :status).all
      end
    end
  end
end

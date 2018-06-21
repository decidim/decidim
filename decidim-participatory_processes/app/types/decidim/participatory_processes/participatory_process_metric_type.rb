# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    ParticipatoryProcessMetricType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::ParticipatoryProcesses::ParticipatoryProcessMetricInterface }]

      name "ParticipatoryProcessMetricType"
      description "A participatory process component of a participatory space."

      field :count, !types.Int, "Total participatory processes" do
        resolve ->(organization, _args, _ctx) {
          ParticipatoryProcessMetricTypeHelper.base_scope(organization).count
        }
      end

      field :data, !types[ParticipatoryProcessMetricObjectType], "Data for each participatory process" do
        resolve ->(organization, _args, _ctx) {
          ParticipatoryProcessMetricTypeHelper.base_scope(organization)
        }
      end
    end

    module ParticipatoryProcessMetricTypeHelper
      def self.base_scope(_organization)
        # super(organization).accepted
        ParticipatoryProcess.includes(:scope).all
      end
    end
  end
end

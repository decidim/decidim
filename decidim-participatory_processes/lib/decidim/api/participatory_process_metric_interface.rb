# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    ParticipatoryProcessMetricInterface = GraphQL::InterfaceType.define do
      name "ParticipatoryProcessMetricInterface"
      description "ParticipatoryProcessMetric definition"

      field :count, !types.Int, "Total participatory processeses"

      field :data, !types[ParticipatoryProcessMetricObjectType], "Data for each participatory process"

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end

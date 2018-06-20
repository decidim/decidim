# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    ParticipatoryProcessMetricObjectType = GraphQL::ObjectType.define do
      interfaces [-> { ParticipatoryProcessMetricObjectInterface }]

      name "ParticipatoryProcessMetricObject"
      description "ParticipatoryProcessMetric object data"
    end
  end
end

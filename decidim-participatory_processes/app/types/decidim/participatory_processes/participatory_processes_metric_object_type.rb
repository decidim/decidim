# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    ParticipatoryProcessesMetricObjectType = GraphQL::ObjectType.define do
      interfaces [-> { ParticipatoryProcessesMetricObjectInterface }]

      name "ParticipatoryProcessesMetricObject"
      description "ParticipatoryProcessesMetric object data"
    end
  end
end

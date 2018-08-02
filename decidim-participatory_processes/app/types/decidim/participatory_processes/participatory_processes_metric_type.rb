# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    ParticipatoryProcessesMetricType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Core::MetricInterface }]

      name "ParticipatoryProcessesMetricType"
      description "A participatory process component of a participatory space."
    end
  end
end

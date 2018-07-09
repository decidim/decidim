# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    ParticipatoryProcessesMetricType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::ParticipatoryProcesses::ParticipatoryProcessesMetricInterface }]

      name "ParticipatoryProcessesMetricType"
      description "A participatory process component of a participatory space."
    end

    module ParticipatoryProcessesMetricTypeHelper
      def self.base_scope(organization, type = :count)
        Rails.cache.fetch("participatory_processes_metric/#{organization.try(:id)}/#{type}", expires_in: 24.hours) do
          Decidim::ParticipatoryProcesses::Metrics::ParticipatoryProcessesMetricCount.for(organization, counter_type: type)
        end
      end
    end
  end
end

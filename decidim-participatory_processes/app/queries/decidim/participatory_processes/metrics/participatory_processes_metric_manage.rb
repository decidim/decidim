# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Metrics
      class ParticipatoryProcessesMetricManage < Decidim::MetricManage
        def initialize(day_string, organization)
          super(day_string, organization)
          @metric_name = "participatory_processes"
        end

        private

        def query
          return @query if @query

          @query = Decidim::ParticipatoryProcess.where(organization: @organization)
          @query = @query.where("decidim_participatory_processes.published_at <= ?", end_time)
          @query
        end

        def quantity
          @quantity ||= query.where("decidim_participatory_processes.published_at >= ?", start_time).count
        end
      end
    end
  end
end

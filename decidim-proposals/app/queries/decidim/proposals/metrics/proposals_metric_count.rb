# frozen_string_literal: true

module Decidim
  module Proposals
    module Metrics
      class ProposalsMetricCount < Decidim::MetricCount
        def self.for(organization, counter_field: :cumulative, group_by: :day)
          super(organization, "proposals", counter_field: counter_field, group_by: group_by)
        end
      end
    end
  end
end

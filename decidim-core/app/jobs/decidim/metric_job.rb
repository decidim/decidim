# frozen_string_literal: true

module Decidim
  class MetricJob < ApplicationJob
    queue_as :metrics

    def perform(manager_class, organization_id, day = nil)
      metric = manager_class.constantize.for(day)
      metric.with_context(Decidim::Organization.find_by(id: organization_id))
      metric.query
      metric.registry!
    end
  end
end

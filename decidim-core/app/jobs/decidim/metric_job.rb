# frozen_string_literal: true

module Decidim
  class MetricJob < ApplicationJob
    queue_as :metrics

    def perform(manager_class, organization_id, day = nil)
      organization = Decidim::Organization.find_by(id: organization_id)
      return unless organization

      metric = manager_class.constantize.new(day, organization)
      metric.save if metric.valid?
    end
  end
end

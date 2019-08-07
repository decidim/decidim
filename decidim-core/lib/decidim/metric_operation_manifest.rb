# frozen_string_literal: true

module Decidim
  # This class acts as a manifest for metrics operations.
  #
  # This manifest is an expansion from Decidim::MetricManifest that holds and stores
  # operations, metrics and measure class, for operations purpose
  #
  class MetricOperationManifest < Decidim::MetricManifest
    attribute :metric_operation, String

    validates :metric_operation, presence: true

    def calculate(day, resource)
      operation = manager_class.constantize.new(day, resource)
      return unless operation.valid?

      operation.calculate
    end
  end
end

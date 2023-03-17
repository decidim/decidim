# frozen_string_literal: true

module Decidim
  class MetricOperation
    # Public: Registers a operation for metrics
    #
    # metric_operation - a symbol representing the name of the operation involved
    # metric_name - a symbol representing the name of the metric involved
    #
    # Returns nothing. Raises an error if there's already a metric
    # registered with that metric name.
    def register(metric_operation, metric_name)
      metric_operation = metric_operation.to_s
      metric_name = metric_name.to_s
      metric_exists = self.for(metric_operation, metric_name).present?

      if metric_exists
        raise(
          MetricOperationAlreadyRegistered,
          "There's a metric already registered with the name `:#{metric_name}`, must be unique"
        )
      end

      metric_manifest = MetricOperationManifest.new(metric_operation:, metric_name:)

      yield(metric_manifest)

      metric_manifest.validate!

      metrics_manifests << metric_manifest
    end

    # Searches for MetricOperationManifest(s) depending on parameters
    # With 'metric_operation' only:
    #   - Returns all manifest related to that operation
    # With 'metric_operation' and 'metric_name':
    #   - Returns a single manifest related to that two params
    def for(metric_operation, metric_name = nil)
      if metric_name
        all.find { |manifest| manifest.metric_operation == metric_operation.to_s && manifest.metric_name == metric_name.to_s }
      else
        all.find_all { |manifest| manifest.metric_operation == metric_operation.to_s }
      end
    end

    def all
      metrics_manifests
    end

    class MetricOperationAlreadyRegistered < StandardError; end

    private

    def metrics_manifests
      @metrics_manifests ||= []
    end
  end
end

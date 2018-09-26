# frozen_string_literal: true

module Decidim
  # This class acts as a registry for metrics. Each metric needs a name
  # and a manager class, that will be used for calculations
  #
  # In order to register a metric, you can follow this example:
  #
  #     Decidim.metrics_registry.register(
  #       :users_metric,
  #       "Decidim::Metrics::UsersMetricManage"
  #     )
  #
  # Metrics need to be registered in the `engine.rb` file of each module
  class MetricRegistry
    HIGHLIGHTED = "highlighted"
    NOT_HIGHLIGHTED = "not-highlighted"
    # Public: Registers a metric for calculations
    #
    # metric_name - a symbol representing the name of the metric
    #
    # manager_class - Manager class for specific metric calculation
    #
    # highlighted - value referencing if it's a highluithgted metric, or not
    #
    # Returns nothing. Raises an error if there's already a metric
    # registered with that metric name.
    def register(metric_name, manager_class, highlighted = NOT_HIGHLIGHTED)
      metric_name = metric_name.to_s
      metric_exists = self.for(metric_name).present?

      if metric_exists
        raise(
          MetricAlreadyRegistered,
          "There's a metric already registered with the name `:#{metric_name}`, must be unique"
        )
      end

      metric_manifest = MetricManifest.new(metric_name: metric_name, manager_class: manager_class, highlighted: highlighted)

      metric_manifest.validate!

      metrics_manifests << metric_manifest
    end

    def for(metric_name)
      all.find { |manifest| manifest.metric_name == metric_name }
    end

    def all
      metrics_manifests
    end

    def highlighted
      all.find_all { |manifest| manifest.highlighted == HIGHLIGHTED }
    end

    def not_highlighted
      all.find_all { |manifest| manifest.highlighted == NOT_HIGHLIGHTED }
    end

    class MetricAlreadyRegistered < StandardError; end

    private

    def metrics_manifests
      @metrics_manifests ||= []
    end
  end
end

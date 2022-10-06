# frozen_string_literal: true

module Decidim
  # This class acts as a registry for metrics. Each metric needs a name
  # and a manager class, that will be used for calculations
  #
  #   Also, each metrics must have a collection of attributes:
  #     - highlighted: Determines if it showed in a highlighted chart
  #     - scopes: List of scopes where it will be used
  #     - weight: Priority of itself
  #
  # In order to register a metric, you can follow this example:
  #
  #     Decidim.metrics_registry.register(:users) do
  #       metric_registry.manager_class = "Decidim::Metrics::UsersMetricManage"
  #
  #       metric_registry.settings do |settings|
  #         settings.attribute :highlighted, type: :boolean, default: true
  #         settings.attribute :scopes, type: :array, default: %w(home)
  #         settings.attribute :weight, type: :integer, default: 1
  #       end
  #     end
  #
  # Metrics need to be registered in the `engine.rb` file of each module
  class MetricRegistry
    # Public: Registers a metric for calculations
    #
    # metric_name - a symbol representing the name of the metric
    #
    # Returns nothing. Raises an error if there's already a metric
    # registered with that metric name.
    def register(metric_name)
      metric_name = metric_name.to_s
      metric_exists = self.for(metric_name).present?

      if metric_exists
        raise(
          MetricAlreadyRegistered,
          "There's a metric already registered with the name `:#{metric_name}`, must be unique"
        )
      end

      metric_manifest = MetricManifest.new(metric_name:)

      yield(metric_manifest)

      metric_manifest.validate!

      metrics_manifests << metric_manifest
    end

    def for(metric_name, list = nil)
      list ||= all
      list.find { |manifest| manifest.metric_name == metric_name.to_s }
    end

    def all
      metrics_manifests
    end

    def filtered(highlight: nil, scope: nil, sort: nil, block: nil)
      result = all
      unless highlight.nil?
        result = if highlight
                   highlighted(result)
                 else
                   not_highlighted(result)
                 end
      end
      result = scoped(scope, result) if scope.present?
      result = sorted(result) if sort.present?
      result = stat_block(block, result) if block.present?
      result
    end

    def highlighted(list = nil)
      list ||= all
      list.find_all { |manifest| manifest.settings.attributes[:highlighted][:default] }
    end

    def not_highlighted(list = nil)
      list ||= all
      list.find_all { |manifest| !manifest.settings.attributes[:highlighted][:default] }
    end

    def scoped(scope, list = nil)
      list ||= all
      list.find_all { |manifest| manifest.settings.attributes[:scopes][:default].include?(scope.to_s) }
    end

    def stat_block(block, list = nil)
      list ||= all
      list.find_all { |manifest| manifest.stat_block == block.to_s }
    end

    def sorted(list = nil)
      list ||= all
      list.sort_by { |manifest| manifest.settings.attributes[:weight].default }
    end

    class MetricAlreadyRegistered < StandardError; end

    private

    def metrics_manifests
      @metrics_manifests ||= []
    end
  end
end

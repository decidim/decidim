# frozen_string_literal: true

module Decidim
  module Exporters
    # This class serializes all metrics, so they can be
    # exported to CSV, JSON or other formats.
    class MetricSerializer < Decidim::Exporters::Serializer
      # Public: Initializes the serializer with a metric.
      def initialize(metric)
        @metric = metric
      end

      attr_reader :metric

      # Public: Exports a hash with the serialized data for this metric.
      def serialize
        byebug
        {
          day: metric.day,
          metric_type: metric.metric_type,
          cumulative: metric.cumulative,
          quantity: metric.quantity
        }
      end
    end
  end
end

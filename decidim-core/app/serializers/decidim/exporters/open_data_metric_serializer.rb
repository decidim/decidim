# frozen_string_literal: true

module Decidim
  module Exporters
    class OpenDataMetricSerializer < Decidim::Exporters::Serializer
      # Public: Initializes the serializer with a resource
      def initialize(resource)
        @resource = resource
      end

      # Public: Exports a hash with the serialized data for this resource.
      def serialize
        {
          day: resource.day,
          metric_type: resource.metric_type,
          cumulative: resource.cumulative,
          quantity: resource.quantity
        }
      end
    end
  end
end

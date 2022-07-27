# frozen_string_literal: true

module Decidim
  module Exporters
    # This is an abstract class with a very naive default implementation
    # for the exporters to use. It can also serve as a superclass of your
    # own implementation.
    #
    # It is used to be run against each element of an exportable collection
    # in order to extract relevant fields. Every export should specify their
    # own serializer or this default will be used.
    class Serializer
      attr_reader :resource

      # Initializes the serializer with a resource.
      #
      # resource - The Object to serialize.
      def initialize(resource)
        @resource = resource
      end

      # Publishes a serialize event and returns serialized hash by default (can be customized at the event).
      def run
        finalize(serialize)
      end

      # Public: Returns a serialized view of the provided resource.
      #
      # Returns a nested Hash with the fields.
      def serialize
        @resource.to_h
      end

      # Public: Publishes notification (event) so that subscribers can modify serialized data.
      #
      # serialized_data - Hash with the serialized data for this resource.
      #
      # Returns a nested Hash with the fields by default.
      def finalize(serialized_data)
        event_data = {
          resource:,
          serialized_data:
        }
        ActiveSupport::Notifications.publish(event_name, event_data)

        event_data[:serialized_data]
      end

      # Public: Converts serializers class name to event name.
      #
      # For example: Decidim::Budgets::ProjectSerializer -> "decidim.serialize.budgets.project_serializer"
      #
      # Returns String
      def event_name
        ActiveSupport::Inflector.underscore(self.class.to_s).sub("/", ".serialize.").gsub("/", ".")
      end
    end
  end
end

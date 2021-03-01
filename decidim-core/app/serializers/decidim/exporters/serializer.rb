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

      # Public: Returns a serialized view of the provided resource.
      #
      # Returns a nested Hash with the fields.
      def serialize
        @resource.to_h
      end

      def finalize(resource, serialized_data)
        event_data = {
          serialized_data: serialized_data,
          resource: resource
        }
        ActiveSupport::Notifications.publish(event_name, event_data)

        event_data[:serialized_data]
      end

      def event_name
        self.class.to_s.downcase.gsub("::", ".")
      end
    end
  end
end

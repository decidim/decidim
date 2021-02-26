# frozen_string_literal: true

module Decidim
  class SerializerManager
    attr_accessor :serializeable
    attr_reader :resource

    def initialize(serializeable, resource)
      @serializeable = serializeable
      @resource = resource
    end

    def publish(event_name)
      ActiveSupport::Notifications.publish(
        event_name,
        klass: self,
        serializeable: serializeable,
        resource: resource
      )
      serializeable
    end
  end
end

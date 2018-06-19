# frozen_string_literal: true

module Decidim
  class Notification < ApplicationRecord
    include Decidim::DataPortability

    belongs_to :resource, foreign_key: "decidim_resource_id", foreign_type: "decidim_resource_type", polymorphic: true
    belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"

    def event_class_instance
      @event_class_instance ||= event_class.constantize.new(resource: resource, event_name: event_name, user: user, extra: extra)
    end

    def self.user_collection(user)
      where(decidim_user_id: user.id)
    end

    def self.export_serializer
      Decidim::DataPortabilitySerializers::DataPortabilityNotificationSerializer
    end
  end
end

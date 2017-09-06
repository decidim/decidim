# frozen_string_literal: true

module Decidim
  class Notification < ApplicationRecord
    belongs_to :resource, foreign_key: "decidim_resource_id", foreign_type: "decidim_resource_type", polymorphic: true
    belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"

    def event_class_instance
      @event_class_instance ||= event_class.constantize.new(resource: resource, event_name: event_name, user: user, extra: extra)
    end
  end
end

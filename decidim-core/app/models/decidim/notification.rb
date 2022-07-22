# frozen_string_literal: true

module Decidim
  class Notification < ApplicationRecord
    include Decidim::DownloadYourData

    belongs_to :resource, foreign_key: "decidim_resource_id", foreign_type: "decidim_resource_type", polymorphic: true
    belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"

    # Daily notifications should contain all notifications within the previous
    # day from the given day.
    scope :daily, ->(time: Time.now.utc) { where(created_at: (time - 1.day).all_day) }

    # Weekly notifications should contain all notifications within the previous
    # week counting from the end of the previous day until the start of the day
    # 1 week ago from the previous day.
    scope :weekly, lambda { |time: Time.now.utc|
      end_of_previous_day = (time - 1.day).end_of_day
      where(created_at: (end_of_previous_day - 7.days).beginning_of_day..end_of_previous_day)
    }

    def event_class_instance
      @event_class_instance ||= event_class.constantize.new(
        resource: resource,
        event_name: event_name,
        user: user,
        user_role: user_role,
        extra: extra
      )
    end

    def user_role
      extra["received_as"]
    end

    def self.user_collection(user)
      where(decidim_user_id: user.id)
    end

    def self.export_serializer
      Decidim::DownloadYourDataSerializers::DownloadYourDataNotificationSerializer
    end
  end
end

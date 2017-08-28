# frozen_string_literal: true

module Decidim
  class Notification < ApplicationRecord
    belongs_to :resource, foreign_key: "decidim_resource_id", foreign_type: "decidim_resource_type", polymorphic: true
    belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"

    validates :user, :resource, presence: true

    def self.unread
      where(read_at: nil)
    end

    def self.read
      where.not(read_at: nil)
    end

    def unread?
      !read?
    end

    def read?
      read_at.present?
    end

    def event_class_instance
      @event_class_instance ||= event_class.constantize.new(resource: resource, event_name: event_name, user: user)
    end
  end
end

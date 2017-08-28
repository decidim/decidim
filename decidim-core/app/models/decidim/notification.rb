# frozen_string_literal: true

module Decidim
  class Notification < ApplicationRecord
    belongs_to :followable, foreign_key: "decidim_followable_id", foreign_type: "decidim_followable_type", polymorphic: true
    belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"

    validates :user, :followable, presence: true

    def event_class_instance
      @event_class_instance ||= event_class.constantize.new(resource: followable, event_name: notification_type, user: user)
    end
  end
end

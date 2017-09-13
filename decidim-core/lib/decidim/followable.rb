# frozen_string_literal: true

module Decidim
  # This concern contains the logic related to followable resources. Events happening todo
  # these resources will generate notifications to the followers.
  module Followable
    extend ActiveSupport::Concern

    included do
      has_many :follows, as: :followable, foreign_key: "decidim_followable_id", foreign_type: "decidim_followable_type", class_name: "Decidim::Follow"
      has_many :followers, through: :follows, source: :user

      # Defines which users will receive the notification. This method can be overridden
      # at each resource model to include or exclude other users, eg. admins.
      #
      # Returns an Array.
      def users_to_notify
        followers
      end
    end
  end
end

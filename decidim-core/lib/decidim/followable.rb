# frozen_string_literal: true

module Decidim
  # This concern contains the logic related to followable resources. Events happening todo
  # these resources will generate notifications to the followers.
  module Followable
    extend ActiveSupport::Concern

    included do
      include Decidim::Notifiable

      has_many :follows, as: :followable, foreign_key: "decidim_followable_id", foreign_type: "decidim_followable_type", class_name: "Decidim::Follow"
      has_many :followers, through: :follows, source: :user

      # Defines when a Followable resource is notifiable. We set this to `true` by default
      # as it's the basic behaviour, but it can be overridden at each resource model.
      # Overriding this method can be useful to avoid notifications when, for example,
      # a proposal author updates the proposal (we don't want them to receive that
      # notification). This will depend on what events trigger notifications for each
      # resource, though.
      #
      # _context - unused param. Should be a Hash.
      #
      # Returns a boolean.
      def notifiable?(_context)
        true
      end

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

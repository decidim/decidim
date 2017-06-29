# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # Shared behaviour for notifiable models.
  module Notifiable
    extend ActiveSupport::Concern

    included do
      # Public: Whether the object's comments are visible or not.
      def notifiable?(_context)
        true
      end

      # Public: A collection of users to send the notifications.
      def users_to_notify
        []
      end
    end
  end
end

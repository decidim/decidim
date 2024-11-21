# frozen_string_literal: true

module Decidim
  module Admin
    class BulkAction < Decidim::Command
      # Public: Initializes the command.

      def initialize(user, moderation_ids, action)
        @user = user
        @moderation_ids = moderation_ids
        @action = action
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the resource.
      # - :invalid if the resource is not reported
      #
      # Returns nothing.
      def call
        # return broadcast(:invalid) unless
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  module Admin
    class BulkUnblockUser < Decidim::Command
      # Public: Initializes the command.

      def initialize(user, moderated_user_ids)
        @user = user
        @moderated_user_ids = moderated_user_ids
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the resource.
      # - :invalid if the resource is not reported
      #
      # Returns nothing.
      def call
        # return broadcast(:invalid) if .blank?

        bulk_action!

        broadcast(:ok)
      end

      private

      attr_reader :user, :moderated_user_ids

      def bulk_action!; end
    end
  end
end

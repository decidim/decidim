# frozen_string_literal: true

module Decidim
  module Admin
    class BulkUnblockUser < Decidim::Command
      # Public: Initializes the command.

      def initialize(user)
        @user = user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the resource.
      # - :invalid if the resource is not reported
      #
      # Returns nothing.
      def call; end

      private

      attr_reader :user, :user_ids
    end
  end
end

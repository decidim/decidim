# frozen_string_literal: true

module Decidim
  module Admin
    class BulkUnblockUser < Decidim::Command
      # Public: Initializes the command.

      def initialize(blocked_users, current_user)
        @blocked_users = blocked_users
        @current_user = current_user
        @result = { ok: [], ko: [] }
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the resource.
      # - :invalid if the resource is not reported
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if blocked_users.blank?

        blocked_users.each do |blocked_user|
          UnblockUser.call(blocked_user, current_user) do
            on(:ok) do
              result[:ok] << blocked_user
            end
            on(:invalid) do
              result[:ko] << blocked_user
            end
          end
        end
        broadcast(:ok, **result)
      end

      private

      attr_reader :current_user, :blocked_users, :result
    end
  end
end

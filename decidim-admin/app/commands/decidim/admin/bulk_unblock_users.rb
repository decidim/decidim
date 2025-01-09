# frozen_string_literal: true

module Decidim
  module Admin
    class BulkUnblockUsers < Decidim::Command
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

        unblock_users!
        create_action_log if first_unblocked

        broadcast(:ok, **result)
      end

      private

      attr_reader :current_user, :blocked_users, :result, :first_unblocked

      def create_action_log
        Decidim::ActionLogger.log(
          "bulk_unblock",
          current_user,
          first_unblocked,
          nil,
          extra: {
            unblocked:,
            reportable_type: first_unblocked.class.name
          }
        )
      end

      def unblocked
        @unblocked ||= result[:ok].to_h { |blocked_user| [blocked_user.id, blocked_user.extended_data["user_name"]] }
      end

      def unblock_users!
        blocked_users.each do |blocked_user|
          transaction do
            blocked_user.blocked = false
            blocked_user.blocked_at = nil
            blocked_user.block_id = nil
            blocked_user.name = blocked_user.extended_data["user_name"]
            blocked_user.save!
          end
          result[:ok] << blocked_user
          @first_unblocked ||= blocked_user
        rescue ActiveRecord::RecordInvalid
          result[:ko] << blocked_user
        end
      end
    end
  end
end

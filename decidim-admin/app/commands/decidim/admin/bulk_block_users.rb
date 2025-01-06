# frozen_string_literal: true

module Decidim
  module Admin
    class BulkBlockUsers < Decidim::Command
      # Public: Initializes the command.
      def initialize(form)
        @form = form
        @result = { ok: [], ko: [] }
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the resource.
      # - :invalid if the resource is not reported
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless form.valid?

        block_all_users!
        create_action_log if first_blocked

        broadcast(:ok, **result)
      end

      private

      attr_reader :form, :result, :first_blocked

      def create_action_log
        Decidim::ActionLogger.log(
          "bulk_block",
          form.current_user,
          first_blocked,
          nil,
          extra: {
            blocked:,
            reportable_type: first_blocked.class.name,
            current_justification: form.justification
          }
        )
      end

      def blocked
        @blocked ||= result[:ok].to_h { |user| [user.id, user.extended_data["user_name"]] }
      end

      def block_all_users!
        form.users.each do |user|
          transaction do
            Decidim::UserModeration.find_or_create_by!(user:)

            @current_blocking = UserBlock.create!(
              justification: form.justification,
              user:,
              blocking_user: form.current_user
            )

            user.blocked = true
            user.blocked_at = Time.current
            user.block_id = @current_blocking.id
            user.extended_data["user_name"] = user.name
            user.name = "Blocked user"
            user.save!
          end
          result[:ok] << user
          @first_blocked ||= user
        rescue ActiveRecord::RecordInvalid
          result[:ko] << user
        end
      end
    end
  end
end

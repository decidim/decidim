# frozen_string_literal: true

module Decidim
  module Admin
    class BlockUser < Decidim::Command
      # Public: Initializes the command.
      #
      # form - BlockUserForm
      def initialize(form)
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the resource.
      # - :invalid if the resource is not reported
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless form.valid?

        transaction do
          block!
          register_justification!
          notify_user!
        end

        broadcast(:ok, form.user)
      end

      private

      attr_reader :form

      def register_justification!
        @current_blocking = UserBlock.create!(
          justification: form.justification,
          user: form.user,
          blocking_user: form.current_user
        )
      end

      def notify_user!
        Decidim::BlockUserJob.perform_later(
          @current_blocking.user,
          @current_blocking.justification
        )
      end

      def block!
        Decidim.traceability.perform_action!(
          "block",
          form.user,
          form.current_user,
          extra: {
            reportable_type: form.user.class.name,
            current_justification: form.justification
          },
          resource: {
            # Make sure the action log entry gets the original user name instead
            # of "Blocked user". Otherwise the log entries would show funny
            # messages such as "Mr. Admin blocked user Blocked user"-
            title: form.user.name
          }
        ) do
          form.user.blocked = true
          form.user.blocked_at = Time.current
          form.user.blocking = @current_blocking
          form.user.extended_data["user_name"] = form.user.name
          form.user.name = "Blocked user"
          form.user.save!
        end
      end
    end
  end
end

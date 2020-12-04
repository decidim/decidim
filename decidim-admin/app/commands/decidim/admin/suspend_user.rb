# frozen_string_literal: true

module Decidim
  module Admin
    class SuspendUser < Rectify::Command
      # Public: Initializes the command.
      #
      # form - SuspendUserForm
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
          suspend!
          register_justification!
          notify_user!
        end

        broadcast(:ok, form.user)
      end

      private

      attr_reader :form

      def register_justification!
        @current_suspension = UserSuspension.create!(
          justification: form.justification,
          user: form.user,
          suspending_user: form.current_user
        )
      end

      def notify_user!
        Decidim::UserSuspensionJob.perform_later(@current_suspension.suspending_user,
                                                        @current_suspension.user,
                                                        @current_suspension.justification)
      end

      def suspend!
        Decidim.traceability.perform_action!(
          "suspend",
          form.user,
          form.current_user,
          extra: {
            reportable_type: form.user.class.name,
            current_justification: form.justification
          }
        ) do
          form.user.suspended = true
          form.user.suspended_at = Time.current
          form.user.suspension = @current_suspension
          form.user.extended_data["user_name"] = form.user.name
          form.user.name = "Blocked user"
          form.user.save!
        end
      end
    end
  end
end

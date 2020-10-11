# frozen_string_literal: true

module Decidim
  module Admin
    class SuspendUser < Rectify::Command
      # Public: Initializes the command.
      #
      # reportable - A Decidim::Reportable
      # current_user - the user performing the action
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
        end

        notify_user!

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

      end

      def suspend!
        Decidim.traceability.perform_action!(
          "suspend",
          form.user,
          form.current_user,
          extra: {
            reportable_type: form.user.class.name
          }
        ) do
          form.user.suspended = true
          form.user.suspended_at = Time.current
          form.user.suspension = @current_suspension
          form.user.save!
        end
      end
    end
  end
end

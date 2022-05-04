# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic to transfer a managed user.
    class TransferUser < Decidim::Command
      # Public: Initializes the command.
      #
      # form
      # user         - The current user
      # managed_user - The managed User
      def initialize(form)
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the impersonation is not valid.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless form.valid?

        transaction do
          update_managed_user
          mark_conflict_as_solved
          create_action_log
        end

        broadcast(:ok)
      end

      private

      attr_reader :form

      def new_user
        form.conflict.current_user
      end

      def managed_user
        form.conflict.managed_user
      end

      def current_user
        form.current_user
      end

      def update_managed_user
        clean_email_and_delete_new_user if form.email == new_user.email
        managed_user.email = form.email
        managed_user.encrypted_password = new_user.encrypted_password
        managed_user.confirmed_at = new_user.confirmed_at
        managed_user.managed = false
        managed_user.skip_reconfirmation!
        managed_user.save!
      end

      def clean_email_and_delete_new_user
        new_user.update(deleted_at: Time.now.utc, email: "")
      end

      def mark_conflict_as_solved
        form.conflict.update(solved: true)
      end

      def create_action_log
        Decidim.traceability.perform_action!(
          "transfer",
          form.conflict.managed_user,
          current_user,
          visibility: "admin-only"
        )
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic to transfer a managed user.
    class TransferUser < Rectify::Command
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
          update_managed_user_email
          mark_conflict_as_solved
        end

        broadcast(:ok)
      end

      private

      attr_reader :form

      def current_user
        form.user
      end

      def managed_user
        form.managed_user
      end

      def update_managed_user_email
        clean_email_and_delete_current_user if form.email == form.user.email
        managed_user.update(email: form.email)
      end

      def clean_email_and_delete_current_user
        current_user.update(deleted_at: Time.now.utc, email: "")
      end

      def mark_conflict_as_solved
        form.conflict.update(solved: true)
      end
    end
  end
end

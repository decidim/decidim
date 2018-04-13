# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic to create a new managed user in the
    # admin panel.
    class CreateManagedUser < Rectify::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      def initialize(form)
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        transaction do
          managed_user.save! unless managed_user.persisted?

          raise ActiveRecord::Rollback unless impersonation_ok?

          broadcast(:ok)
        end
      end

      private

      attr_reader :form

      def managed_user
        form.user
      end

      def impersonation_ok?
        ImpersonateUser.call(form) do
          on(:ok) do
            return true
          end
          on(:invalid) do
            return false
          end
        end
      end
    end
  end
end

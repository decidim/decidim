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
          unless managed_user.persisted?
            managed_user.update!(admin: false, tos_agreement: true)
          end

          raise ActiveRecord::Rollback unless authorized_user? && impersonation_ok?

          broadcast(:ok)
        end
      end

      private

      attr_reader :form, :user

      def managed_user
        @managed_user ||= Decidim::User.find_or_initialize_by(
          organization: form.current_organization,
          managed: true,
          name: form.name
        )
      end

      def impersonation_ok?
        ImpersonateManagedUser.call(form, managed_user) do
          on(:ok) do
            return true
          end
          on(:invalid) do
            return false
          end
        end
      end

      def authorized_user?
        form.authorization.user = managed_user
        Verifications::AuthorizeUser.call(form.authorization) do
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

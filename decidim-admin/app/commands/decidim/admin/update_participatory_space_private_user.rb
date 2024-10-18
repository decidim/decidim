# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when updating a participatory space
    # private user.
    class UpdateParticipatorySpacePrivateUser < Decidim::Command
      delegate :current_user, to: :form
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      # private_user_to - The private_user_to that will hold the
      #   user role
      def initialize(form, private_user)
        @form = form
        @private_user = private_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form was not valid and we could not proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        update_private_user

        broadcast(:ok)
      rescue ActiveRecord::RecordInvalid
        broadcast(:invalid)
      end

      private

      attr_reader :form, :private_user

      def update_private_user
        Decidim.traceability.perform_action!(
          "update",
          private_user,
          current_user
        ) do
          private_user.update!(
            role: form.role,
            published: form.published
          )
        end
      end
    end
  end
end

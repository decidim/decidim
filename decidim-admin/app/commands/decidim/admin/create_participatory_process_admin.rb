# frozen_string_literal: true
module Decidim
  module Admin
    # A command with all the business logic when creating a new participatory
    # process admin in the system.
    class CreateParticipatoryProcessAdmin < Rectify::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      # participatory_process - The ParticipatoryProcess that will hold the
      #   user role
      def initialize(form, participatory_process)
        @form = form
        @participatory_process = participatory_process
      end

      # Executes the command. Braodcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?
        return broadcast(:invalid) unless user

        create_participatory_process_admin
        broadcast(:ok)
      end

      private

      attr_reader :form, :participatory_process

      def create_participatory_process_admin
        ParticipatoryProcessUserRole.create!(
          role: :admin,
          user: user,
          participatory_process: @participatory_process
        )
      end

      def user
        User.where(
          email: form.email,
          organization: participatory_process.organization
        ).first
      end
    end
  end
end

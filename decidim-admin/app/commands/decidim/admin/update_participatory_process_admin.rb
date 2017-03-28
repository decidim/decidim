# frozen_string_literal: true
module Decidim
  module Admin
    # A command with all the business logic when updated a participatory
    # process admin in the system.
    class UpdateParticipatoryProcessAdmin < Rectify::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      # participatory_process - The ParticipatoryProcess that will hold the
      #   user role
      def initialize(form, user_role)
        @form = form
        @user_role = user_role
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?
        return broadcast(:invalid) unless user_role

        update_role!
        broadcast(:ok)
      end

      private

      attr_reader :form, :user_role

      def update_role!
        user_role.update_attributes!(role: form.role)
      end
    end
  end
end

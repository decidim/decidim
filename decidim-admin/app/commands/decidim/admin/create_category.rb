# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic to create a new category in the
    # system.
    class CreateCategory < Decidim::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      # participatory_space - The participatory space that will hold the
      #   category
      def initialize(form, participatory_space, user)
        @form = form
        @participatory_space = participatory_space
        @user = user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        create_category
        broadcast(:ok)
      end

      private

      attr_reader :form

      def create_category
        Decidim.traceability.create!(
          Category,
          @user,
          name: form.name,
          weight: form.weight,
          parent_id: form.parent_id,
          participatory_space: @participatory_space
        )
      end
    end
  end
end

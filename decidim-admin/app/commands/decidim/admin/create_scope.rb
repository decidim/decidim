# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when creating a static scope.
    class CreateScope < Rectify::Command
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

        create_scope
        broadcast(:ok)
      end

      private

      attr_reader :form

      def create_scope
        Scope.create!(
          name: form.name,
          organization: form.organization
        )
      end
    end
  end
end

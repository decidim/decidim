# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when creating an area type.
    class CreateAreaType < Decidim::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      def initialize(form, user)
        @form = form
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

        create_area_type
        broadcast(:ok)
      end

      private

      attr_reader :form

      def create_area_type
        Decidim.traceability.create!(
          AreaType,
          @user,
          name: form.name,
          organization: form.organization,
          plural: form.plural
        )
      end
    end
  end
end

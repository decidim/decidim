# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when updating an area.
    class UpdateArea < Rectify::Command
      # Public: Initializes the command.
      #
      # area - The Area to update
      # form - A form object with the params.
      def initialize(area, form)
        @area = area
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

        update_area
        broadcast(:ok)
      end

      private

      attr_reader :form

      def update_area
        Decidim.traceability.update!(
          @area,
          form.current_user,
          attributes
        )
      end

      def attributes
        {
          name: form.name,
          area_type: form.area_type
        }
      end
    end
  end
end

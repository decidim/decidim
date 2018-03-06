# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when updating an area type.
    class UpdateAreaType < Rectify::Command
      # Public: Initializes the command.
      #
      # area_type - The AreaType to update
      # form - A form object with the params.
      def initialize(area_type, form)
        @area_type = area_type
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

        update_area_type
        broadcast(:ok)
      end

      private

      attr_reader :form

      def update_area_type
        @area_type.update!(attributes)
      end

      def attributes
        {
          name: form.name,
          plural: form.plural
        }
      end
    end
  end
end

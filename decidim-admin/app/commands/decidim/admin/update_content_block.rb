# frozen_string_literal: true

module Decidim
  module Admin
    # This command gets called when a contnt block is updated from the admin panel.
    class UpdateContentBlock < Rectify::Command
      attr_reader :form, :content_block, :scope

      # Public: Initializes the command.
      #
      # form    - The form from which the data in this component comes from.
      # component - The component to update.
      def initialize(form, content_block, scope)
        @form = form
        @content_block = content_block
        @scope = scope
      end

      # Public: Creates the Component.
      #
      # Broadcasts :ok if created, :invalid otherwise.
      def call
        return broadcast(:invalid) if form.invalid?

        update_content_block

        broadcast(:ok)
      end

      private

      def update_content_block
        content_block.settings = form.settings
        content_block.save!
      end
    end
  end
end

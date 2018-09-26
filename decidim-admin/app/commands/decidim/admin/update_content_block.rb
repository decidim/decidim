# frozen_string_literal: true

module Decidim
  module Admin
    # This command gets called when a content block is updated from the admin
    # panel.
    class UpdateContentBlock < Rectify::Command
      attr_reader :form, :content_block, :scope

      # Public: Initializes the command.
      #
      # form    - The form from which the data in this component comes from.
      # component - The component to update.
      # scope - the scope where the content block belongs to.
      def initialize(form, content_block, scope)
        @form = form
        @content_block = content_block
        @scope = scope
      end

      # Public: Updates the content block settings and its attachments.
      #
      # Broadcasts :ok if created, :invalid otherwise.
      def call
        return broadcast(:invalid) if form.invalid?

        transaction do
          update_content_block_settings
          update_content_block_images
          content_block.save!
        end

        broadcast(:ok)
      end

      private

      def update_content_block_settings
        content_block.settings = form.settings
      end

      def update_content_block_images
        content_block.manifest.images.each do |image_config|
          image_name = image_config[:name]

          if form.images["remove_#{image_name}".to_sym]
            content_block.images_container.send("remove_#{image_name}=", true)
          elsif form.images[image_name]
            content_block.images_container.send("#{image_name}=", form.images[image_name])
          end
        end
      end
    end
  end
end

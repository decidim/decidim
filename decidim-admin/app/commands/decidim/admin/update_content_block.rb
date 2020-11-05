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

        images_valid = true

        transaction do
          update_content_block_settings
          content_block.save!

          # Saving the images will cause the image file validations to run
          # according to their uploader settings and the organization settings.
          # The content block validation will fail in case there are processing
          # errors on the image files.
          #
          # NOTE:
          # The images can be only stored correctly if the content block is
          # already persisted. This is not the case e.g. when creating a new
          # newsletter which uses the content blocks through newsletter
          # templates. This is why this needs to happen after the initial
          # `content_block.save!` call.
          update_content_block_images
          unless content_block.valid?
            images_valid = false
            raise ActiveRecord::Rollback
          end

          # The save method needs to be called another time in order to store
          # the image information.
          content_block.save!
        end

        return broadcast(:invalid) unless images_valid

        broadcast(:ok, content_block)
      end

      private

      def update_content_block_settings
        content_block.settings = form.settings
      end

      def update_content_block_images
        content_block.manifest.images.each do |image_config|
          image_name = image_config[:name]

          if form.images[image_name]
            content_block.images_container.send("#{image_name}=", form.images[image_name])
          elsif form.images["remove_#{image_name}".to_sym] == "1"
            content_block.images_container.send("remove_#{image_name}=", true)
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  module Proposals
    # A module with all the gallery common methods for proposals
    # and collaborative draft commands.
    # Allows to create several image attachments at once
    module GalleryMethods
      private

      def build_gallery
        @gallery = []
        @form.add_photos.each do |photo|
          next unless image? photo

          @gallery << Attachment.new(
            title: photo.original_filename,
            file: photo,
            attached_to: @attached_to
          )
        end
      end

      def image?(image)
        return unless image.respond_to? :content_type

        image.content_type.start_with? "image"
      end

      def gallery_invalid?
        gallery.each do |photo|
          if photo.invalid? && photo.errors.has_key?(:file)
            @form.errors.add(:add_photos, photo.errors[:file])
            return true
          end
        end
        false
      end

      def create_gallery
        @gallery.map! do |photo|
          photo.attached_to = @attached_to
          photo.save!
          @form.photos << photo.id.to_s
        end
      end

      def photo_cleanup!
        @attached_to.photos.each do |photo|
          photo.destroy! if @form.photos.exclude? photo.id.to_s
        end
        # manually reset cached photos
        @attached_to.reload
        @attached_to.instance_variable_set(:@photos, nil)
      end

      # maybe a custom settings options would be nice
      def gallery_allowed?
        @form.current_component.settings.attachments_allowed?
      end

      def process_gallery?
        gallery_allowed? && @form.add_photos.any?
      end
    end
  end
end

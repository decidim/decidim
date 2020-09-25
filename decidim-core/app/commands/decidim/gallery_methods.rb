# frozen_string_literal: true

module Decidim
  # A module with all the gallery common methods
  # Allows to create several image attachments at once
  module GalleryMethods
    private

    def build_gallery(attached_to = nil)
      @gallery = []
      @form.add_photos.each do |photo|
        next unless image? photo

        @gallery << Attachment.new(
          title: photo.original_filename,
          attached_to: attached_to || gallery_attached_to,
          file: photo # Define attached_to before this
        )
      end
    end

    def image?(image)
      return unless image.respond_to? :content_type

      image.content_type.start_with? "image"
    end

    def gallery_invalid?
      @gallery.each do |photo|
        if photo.invalid? && photo.errors.has_key?(:file)
          @form.errors.add(:add_photos, photo.errors[:file])
          return true
        end
      end
      false
    end

    def create_gallery
      @gallery.map! do |photo|
        photo.attached_to = gallery_attached_to
        photo.save!
        @form.photos << photo.id.to_s
      end
    end

    def photo_cleanup!
      gallery_attached_to.photos.each do |photo|
        photo.destroy! if @form.photos.exclude? photo.id.to_s
      end
      # manually reset cached photos
      gallery_attached_to.reload
      gallery_attached_to.instance_variable_set(:@photos, nil)
    end

    # maybe a custom settings options would be nice
    def gallery_allowed?
      true
    end

    def process_gallery?
      gallery_allowed? && @form.add_photos.any?
    end

    def gallery_attached_to
      return @attached_to if @attached_to.present?
      return form.current_organization if form.respond_to?(:current_organization)

      form.current_component.organization if form.respond_to?(:current_component)
    end
  end
end

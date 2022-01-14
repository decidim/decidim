# frozen_string_literal: true

module Decidim
  # A module with all the gallery common methods
  # Allows to create several image attachments at once
  module GalleryMethods
    private

    def build_gallery(attached_to = nil)
      @gallery = []
      @form.add_photos.reject(&:blank?).each do |photo|
        next unless image? photo[:file]

        @gallery << Attachment.new(
          title: { I18n.locale => photo[:title] },
          attached_to: attached_to || gallery_attached_to,
          file: photo[:file],
          content_type: blob(photo[:file]).content_type
        )
      end
    end

    def image?(signed_id)
      blob(signed_id).content_type.start_with? "image"
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
        @form.photos << photo
      end
    end

    def photo_cleanup!
      gallery_attached_to.photos.each do |photo|
        photo.destroy! if @form.photos.map(&:id).exclude? photo.id
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

    def blob(signed_id)
      ActiveStorage::Blob.find_signed(signed_id)
    end
  end
end

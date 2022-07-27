# frozen_string_literal: true

module Decidim
  # A module with all the gallery common methods
  # Allows to create several image attachments at once
  module GalleryMethods
    private

    def build_gallery(attached_to = nil)
      @gallery = []
      @form.add_photos.compact_blank.each do |photo|
        if photo.is_a?(Hash) && photo.has_key?(:id)
          update_attachment_title_for(photo)
          next
        end

        @gallery << Attachment.new(
          title: photos_title(photo),
          attached_to: attached_to || gallery_attached_to,
          file: photos_signed_id(photo), # Define attached_to before this
          content_type: photos_content_type(photo)
        )
      end
    end

    def update_attachment_title_for(photo)
      Decidim::Attachment.find(photo[:id]).update(title: title_for(photo))
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

    def create_gallery(first_weight: 0)
      weight = first_weight
      # Add the weights first to the old photos
      @form.photos.each do |photo|
        photo.update!(weight:)
        weight += 1
      end
      @gallery.map! do |photo|
        photo.weight = weight
        photo.attached_to = gallery_attached_to
        photo.save!
        weight += 1
        @form.photos << photo
      end
    end

    def photo_cleanup!
      gallery_attached_to.photos.each do |photo|
        next unless @form.photos.map(&:id).exclude?(photo.id)

        photo.destroy! if (@form.respond_to?(:documents) && @form.documents.map(&:id).exclude?(photo.id)) || !@form.respond_to?(:documents)
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

    def photos_signed_id(photo)
      return photo[:file] if photo.is_a?(Hash)

      photo
    end

    def photos_title(photo)
      return { I18n.locale => photo[:title] } if photo.is_a?(Hash) && photo.has_key?(:title)

      { I18n.locale => "" }
    end

    def photos_content_type(photo)
      blob(photos_signed_id(photo)).content_type
    end

    def blob(signed_id)
      ActiveStorage::Blob.find_signed(signed_id)
    end
  end
end

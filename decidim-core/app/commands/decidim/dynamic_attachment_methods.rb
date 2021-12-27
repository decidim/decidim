# frozen_string_literal: true

module Decidim
  module DynamicAttachmentMethods
    include ::Decidim::MultipleAttachmentsMethods
    include GalleryMethods

    private

    def build_attachments
      @documents = []
      @form.add_documents.each do |attachment|
        @documents << Attachment.new(
          title: { I18n.locale => attachment[:title] },
          attached_to: @attached_to || documents_attached_to,
          file: attachment[:file],
          content_type: blob(attachment[:file].content_type)
        )
      end
    end

    def build_gallery(attached_to = nil)
      @gallery = []
      @form.add_photos.each do |photo|
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

    def blob(signed_id)
      ActiveStorage::Blob.find_signed(signed_id)
    end
  end
end

# frozen_string_literal: true

module Decidim
  module MultipleAttachmentsMethods
    private

    def build_attachments
      @documents = []
      @form.add_documents.compact_blank.each do |attachment|
        if attachment.is_a?(Hash) && attachment.has_key?(:id)
          update_attachment_title_for(attachment)
          next
        end

        @documents << Attachment.new(
          title: title_for(attachment),
          attached_to: @attached_to || documents_attached_to,
          file: signed_id_for(attachment),
          content_type: content_type_for(attachment)
        )
      end
    end

    def update_attachment_title_for(attachment)
      Decidim::Attachment.find(attachment[:id]).update(title: title_for(attachment))
    end

    def attachments_invalid?
      @documents.each do |document|
        next if document.valid? || !document.errors.has_key?(:file)

        document.errors[:file].each do |error|
          @form.errors.add(:add_documents, error)
        end

        return true
      end

      false
    end

    def create_attachments(first_weight: 0)
      weight = first_weight
      # Add the weights first to the old document
      @form.documents.each do |document|
        document.update!(weight: weight)
        weight += 1
      end
      @documents.map! do |document|
        document.weight = weight
        document.attached_to = documents_attached_to
        document.save!
        weight += 1
        @form.documents << document
      end
    end

    def document_cleanup!
      documents_attached_to.documents.each do |document|
        document.destroy! if @form.documents.map(&:id).exclude? document.id
      end

      documents_attached_to.reload
      documents_attached_to.instance_variable_set(:@documents, nil)
    end

    def process_attachments?
      @form.add_documents.any?
    end

    def documents_attached_to
      return @attached_to if @attached_to.present?
      return form.current_organization if form.respond_to?(:current_organization)

      form.current_component.organization if form.respond_to?(:current_component)
    end

    def signed_id_for(attachment)
      return attachment[:file] if attachment.is_a?(Hash)

      attachment
    end

    def title_for(attachment)
      return { I18n.locale => attachment[:title] } if attachment.is_a?(Hash) && attachment.has_key?(:title)

      { I18n.locale => "" }
    end

    def content_type_for(attachment)
      return attachment.content_type if attachment.instance_of?(ActionDispatch::Http::UploadedFile)

      blob(signed_id_for(attachment)).content_type
    end

    def blob(signed_id)
      ActiveStorage::Blob.find_signed(signed_id)
    end
  end
end

# frozen_string_literal: true

module Decidim
  module MultipleAttachmentsMethods
    private

    def build_attachments
      @documents = []
      @form.add_documents.each do |file|
        @documents << Attachment.new(
          title: { I18n.locale => file.original_filename },
          attached_to: @attached_to || documents_attached_to,
          file: file
        )
      end
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

    def create_attachments
      @documents.map! do |document|
        document.attached_to = documents_attached_to
        document.save!
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
  end
end

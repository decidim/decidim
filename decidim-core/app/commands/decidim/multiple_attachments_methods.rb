# frozen_string_literal: true

module Decidim
  module MultipleAttachmentsMethods
    private

    def build_attachments
      @documents = []
      @form.add_documents.each do |file|
        @documents << Attachment.new(
          title: file.original_filename,
          attached_to: @attached_to || documents_attached_to,
          file: file
        )
      end
    end

    def attachments_invalid?
      @documents.each do |file|
        if file.invalid? && file.errors.has_key?(:file)
          @form.errors.add(:add_documents, file.errors[:file])
          return true
        end
      end
      false
    end

    def create_attachments
      @documents.map! do |file|
        file.attached_to = documents_attached_to
        file.save!
        @form.documents << file.id.to_s
      end
    end

    def document_cleanup!
      documents_attached_to.documents.each do |file|
        file.destroy! if @form.documents.exclude? file.id.to_s
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

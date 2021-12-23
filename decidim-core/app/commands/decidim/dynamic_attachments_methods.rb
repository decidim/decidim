# frozen_string_literal: true

module Decidim
  module DynamicAttachmentsMethods
    private

    def build_attachments
      @documents = []
      @form.add_documents.each do |attachment|
        @documents << Attachment.new(
          title: { I18n.locale => attachment[:title] },
          attached_to: @attached_to || documents_attached_to,
          file: attachment[:file],
          content_type: ActiveStorage::Blob.last.content_type # FIX THIS
        )
      end
    end

    def process_attachments?
      @form.add_documents.any?
    end

    def create_attachments
      @documents.map! do |document|
        document.attached_to = documents_attached_to
        document.save!
        @form.documents << document
      end
    end

    def documents_attached_to
      return @attached_to if @attached_to.present?
      return form.current_organization if form.respond_to?(:current_organization)

      form.current_component.organization if form.respond_to?(:current_component)
    end

    def document_cleanup!
      documents_attached_to.documents.each do |document|
        document.destroy! if @form.documents.map(&:id).exclude? document.id
      end

      documents_attached_to.reload
      documents_attached_to.instance_variable_set(:@documents, nil)
    end
  end
end

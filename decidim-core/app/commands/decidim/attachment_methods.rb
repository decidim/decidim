# frozen_string_literal: true

module Decidim
  # A module with all the attachment common methods
  module AttachmentMethods
    private

    def build_attachment(attached_to = nil)
      attached_to = @attached_to if attached_to.blank?
      attached_to = form.current_organization if attached_to.blank? && form.respond_to?(:current_organization)

      @attachment = Attachment.new(
        title: { I18n.locale => @form.attachment.title },
        attached_to:,
        file: @form.attachment.file, # Define attached_to before this
        content_type: @form.attachment.file.content_type
      )
    end

    def delete_attachment(attachment)
      Attachment.find(attachment.id).delete if attachment.id.to_i == proposal.documents.first.id
    end

    def attachment_invalid?
      if attachment.invalid? && attachment.errors.has_key?(:file)
        @form.attachment.errors.add :file, attachment.errors[:file]
        true
      end
    end

    def attachment_present?
      @form.attachment.file.present?
    end

    def attachment_file_uploaded?
      !@form.attachment.file.is_a?(Decidim::ApplicationUploader)
    end

    def create_attachment(weight: 0)
      attachment.weight = weight
      attachment.attached_to = @attached_to
      attachment.save!
    end

    def attachments_allowed?
      @form.current_component.settings.attachments_allowed?
    end

    def process_attachments?
      attachments_allowed? && attachment_present? && attachment_file_uploaded?
    end

    def delete_attachment?
      @form.attachment&.delete_file.present?
    end
  end
end

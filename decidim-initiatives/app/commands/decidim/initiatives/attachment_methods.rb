# frozen_string_literal: true

module Decidim
  module Initiatives
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

      def attachment_invalid?
        if attachment.invalid? && attachment.errors.has_key?(:file)
          @form.attachment.errors.add :file, attachment.errors[:file]
          true
        end
      end

      def create_attachment
        attachment.attached_to = @attached_to
        attachment.save!
      end

      def process_attachments?
        @form.attachment && @form.attachment.file.present? &&
          !@form.attachment.file.is_a?(Decidim::ApplicationUploader)
      end
    end
  end
end

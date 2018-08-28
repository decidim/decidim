# frozen_string_literal: true

module Decidim
  module Proposals
    # A module with all the attachment common methods for proposals
    # and collaborative draft commands.
    module AttachmentMethods
      private

      def build_attachment
        @attachment = Attachment.new(
          title: @form.attachment.title,
          file: @form.attachment.file,
          attached_to: @attached_to
        )
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

      def create_attachment
        attachment.attached_to = @attached_to
        attachment.save!
      end

      def attachments_allowed?
        @form.current_component.settings.attachments_allowed?
      end

      def process_attachments?
        attachments_allowed? && attachment_present?
      end
    end
  end
end

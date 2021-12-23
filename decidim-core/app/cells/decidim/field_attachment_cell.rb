# frozen_string_literal: true

module Decidim
  class FieldAttachmentCell < Decidim::ViewModel
    include Cell::ViewModel::Partial
    include ERB::Util

    alias form model

    def show
      return unless resource_name

      render
    end

    private

    def resource_name
      options[:resource_name]
    end

    def attachment_name
      options[:attachment_name]
    end

    def attachments
      options[:attachments]
    end

    def file_name(attachment)
      attachment.file&.blob&.filename&.sanitized || attachment.url.split("/").last
    end

    def field_id
      @field_id ||= "attachments_#{SecureRandom.uuid}"
    end
  end
end

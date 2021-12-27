# frozen_string_literal: true

module Decidim
  class UploadModalCell < Decidim::ViewModel
    include Cell::ViewModel::Partial
    include ERB::Util

    alias form model

    def show
      return unless resource_name

      render
    end

    private

    def button_inner_html
      return "Edit #{attribute}" if attachments && attachments.count.positive?

      "Add #{attribute}"
    end

    def resource_name
      options[:resource_name]
    end

    def attribute
      options[:attribute]
    end

    def attachments
      options[:attachments] || form.object.send(options[:attribute])
    end

    def file_name(attachment)
      attachment.file&.blob&.filename&.sanitized || attachment.url.split("/").last
    end

    def field_id
      @field_id ||= "attachments_#{SecureRandom.uuid}"
    end

    def current_organization
      controller.current_organization
    end
  end
end

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

    def label
      return edit_label if attachments && attachments.count.positive?

      add_label
    end

    def add_label
      options[:label]
    end

    def edit_label
      options[:edit_label] || add_label
    end

    def resource_name
      options[:resource_name]
    end

    def attribute
      options[:attribute]
    end

    def multiple
      options[:multiple] || false
    end

    def add_attribute
      return "add_#{attribute}" if form.object.respond_to? "add_#{attribute}".to_sym

      attribute.to_sym
    end

    def help_messages
      Array(options[:help])
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

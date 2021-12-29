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

    def button_class
      "button small hollow add-field add-attachment" if has_title?

      "button small primary add-attachment"
    end

    def label
      return edit_label if attachments.count.positive?

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
      return "add_#{attribute}" if form.object.respond_to? "add_#{attribute}"

      attribute
    end

    def has_title?
      options[:titled] == true
    end

    def help_messages
      Array(options[:help])
    end

    def attachments
      @attachments = begin
        attachments = options[:attachments] || form.object.send(options[:attribute])
        Array(attachments)
      end
    end

    def title_for(attachment)
      return unless has_title?

      translated_attribute(attachment.title)
    end

    def file_name_for(attachment)
      filename = begin
        return attachment.file.blob.filename.sanitized if attachment.respond_to? :file
        return attachment.blob.filename.sanitized if attachment.respond_to? :blob
        return blob.filename if attachment.is_a? Array

        attachment.url.split("/").last
      end

      return "(#{filename})" if has_title?

      filename
    end

    # SUPER HACK FIX THIS!!!
    def blob
      @blob ||= ActiveStorage::Blob.find_signed(attachments.last.last)
    end

    def modal_id
      @modal_id ||= "attachments_#{SecureRandom.uuid}"
    end

    def current_organization
      controller.current_organization
    end
  end
end

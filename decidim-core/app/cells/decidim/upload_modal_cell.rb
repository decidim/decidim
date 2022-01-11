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
      options[:label]
    end

    def button_label
      return button_edit_label if attachments.count.positive?

      options[:button_label]
    end

    def button_edit_label
      options[:button_edit_label] || options[:button_label]
    end

    def max_file_size
      options[:max_file_size]
    end

    def max_file_size_mb
      return unless max_file_size

      (((max_file_size / 1024 / 1024) * 100) / 100).round
    end

    def resource_class
      options[:resource_class].to_s
    end

    def resource_name
      options[:resource_name]
    end

    def actions_wrapper_class
      has_title? ? "actions-wrapper titled" : "actions-wrapper"
    end

    def attribute
      options[:attribute]
    end

    def multiple
      options[:multiple] || false
    end

    def optional
      options[:optional]
    end

    def explanation
      return I18n.t("explanation", scope: options[:help_i18n_scope], attribute: attribute) if options[:help_i18n_scope].present?

      I18n.t("explanation", scope: "decidim.forms.upload_help", attribute: attribute)
    end

    def add_attribute
      return "add_#{attribute}" if form.object.respond_to? "add_#{attribute}"

      attribute
    end

    def has_title?
      options[:titled] == true
    end

    def with_title
      "with-title" if has_title?
    end

    def attachment_label
      return I18n.t("current_image", scope: "decidim.forms") if attachments.count.positive? && file_attachment_path(attachments.first).present?

      I18n.t("default_image", scope: "decidim.forms")
    end

    def help_messages
      Array(options[:help])
    end

    def attachments
      @attachments = begin
        attachments = options[:attachments] || form.object.send(attribute)
        Array(attachments).map { |a| a.is_a?(String) ? ActiveStorage::Blob.find_signed(a) : a }
      end
    end

    def id_for(attachment)
      return attachment.id if attachment.respond_to? :id

      rand(1..10_000)
    end

    def title_for(attachment)
      return unless has_title?

      translated_attribute(attachment.title)
    end

    def file_name_for(attachment)
      filename = begin
        return blob(attachment).filename if blob(attachment).present?

        attachment.url.split("/").last
      end

      return "(#{filename})" if has_title?

      filename
    end

    def file_attachment_path(attachment)
      return unless attachment

      if attachment.try(:attached?)
        attachment_path = Rails.application.routes.url_helpers&.rails_blob_url(attachment.blob, only_path: true)
        return attachment_path if attachment_path.present?
      end

      uploader_default_image_path(attribute)
    end

    def uploader_default_image_path(attribute)
      uploader = FileValidatorHumanizer.new(form.object, attribute).uploader
      return if uploader.blank?
      return unless uploader.is_a?(Decidim::ImageUploader)

      uploader.try(:default_url)
    end

    def blob(attachment)
      return ActiveStorage::Blob.find_signed(attachment) if attachment.is_a? String
      return attachment.file.blob if attachment.is_a? Decidim::Attachment
      return attachment.blob if attachment.respond_to? :blob
    end

    def modal_id
      @modal_id ||= "attachments_#{SecureRandom.uuid}"
    end

    def current_organization
      controller.current_organization
    end
  end
end
